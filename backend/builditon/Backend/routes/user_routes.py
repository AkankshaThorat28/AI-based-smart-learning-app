import hashlib
import sqlite3
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database.db_config import get_conn, USE_SUPABASE, supabase

router = APIRouter(prefix="/api/users", tags=["Users"])

# ── Schemas ──────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    role: str = "student"       # "student" | "teacher"
    disability: str = "none"    # "none" | "visual" | "deaf" | "voice"

class LoginRequest(BaseModel):
    email: str
    password: str

class UserOut(BaseModel):
    id: int
    name: str
    email: str
    role: str
    disability: str

# ── Helper ───────────────────────────────────────────────────────────────────

def _hash(pw: str) -> str:
    return hashlib.sha256(pw.encode()).hexdigest()

# ── Register ─────────────────────────────────────────────────────────────────

@router.post("/register", response_model=UserOut, status_code=201)
def register(req: RegisterRequest):
    hashed = _hash(req.password)

    # ── Supabase path ────────────────────────────────────────────────────────
    if USE_SUPABASE:
        existing = supabase.table("users").select("id").eq("email", req.email).execute()
        if existing.data:
            raise HTTPException(409, "Email already registered.")
        res = supabase.table("users").insert({
            "name": req.name, "email": req.email,
            "password": hashed, "role": req.role, "disability": req.disability,
        }).execute()
        u = res.data[0]
        return UserOut(**u)

    # ── SQLite path ──────────────────────────────────────────────────────────
    conn = get_conn()
    try:
        conn.execute(
            "INSERT INTO users (name,email,password,role,disability) VALUES (?,?,?,?,?)",
            (req.name, req.email, hashed, req.role, req.disability),
        )
        conn.commit()
        row = conn.execute("SELECT * FROM users WHERE email=?", (req.email,)).fetchone()
        return UserOut(**dict(row))
    except sqlite3.IntegrityError:
        raise HTTPException(409, "Email already registered.")
    finally:
        conn.close()

# ── Login ────────────────────────────────────────────────────────────────────

@router.post("/login", response_model=UserOut)
def login(req: LoginRequest):
    hashed = _hash(req.password)

    # ── Supabase path ────────────────────────────────────────────────────────
    if USE_SUPABASE:
        res = supabase.table("users").select("*") \
            .eq("email", req.email).eq("password", hashed).execute()
        if not res.data:
            raise HTTPException(401, "Invalid email or password.")
        return UserOut(**res.data[0])

    # ── SQLite path ──────────────────────────────────────────────────────────
    conn = get_conn()
    try:
        row = conn.execute(
            "SELECT * FROM users WHERE email=? AND password=?", (req.email, hashed)
        ).fetchone()
        if not row:
            raise HTTPException(401, "Invalid email or password.")
        return UserOut(**dict(row))
    finally:
        conn.close()

# ── Status ───────────────────────────────────────────────────────────────────

@router.get("/status")
def status():
    return {"message": "User routes active", "db": "supabase" if USE_SUPABASE else "sqlite"}
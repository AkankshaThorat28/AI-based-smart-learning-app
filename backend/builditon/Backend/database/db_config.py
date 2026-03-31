import os
import sqlite3
from dotenv import load_dotenv

load_dotenv()

# ── Try Supabase; silently fall back to SQLite if keys are missing ──────────
url: str = os.environ.get("SUPABASE_URL", "")
key: str = os.environ.get("SUPABASE_KEY", "")

supabase = None
USE_SUPABASE = False

if url and key:
    try:
        from supabase import create_client, Client
        supabase: Client = create_client(url, key)
        USE_SUPABASE = True
        print("✅ Supabase connected")
    except Exception as e:
        print(f"⚠️  Supabase unavailable: {e}  →  falling back to SQLite")
else:
    print("⚠️  SUPABASE credentials not set  →  using local SQLite database")

# ── SQLite Fallback ──────────────────────────────────────────────────────────
_DB_PATH = os.path.join(os.path.dirname(__file__), "local.db")

def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(_DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

def _init_db():
    conn = get_conn()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            name       TEXT    NOT NULL,
            email      TEXT    UNIQUE NOT NULL,
            password   TEXT    NOT NULL,
            role       TEXT    NOT NULL DEFAULT 'student',
            disability TEXT    NOT NULL DEFAULT 'none',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS chat_history (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id    INTEGER NOT NULL,
            message    TEXT    NOT NULL,
            reply      TEXT    NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS quiz_results (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id    INTEGER NOT NULL,
            score      INTEGER NOT NULL,
            total      INTEGER NOT NULL,
            topic      TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    """)
    conn.commit()
    conn.close()

_init_db()
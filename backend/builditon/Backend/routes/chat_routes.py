from fastapi import APIRouter
from pydantic import BaseModel
from ai_core.agentic_assistant import get_ai_response
from database.db_config import get_conn

router = APIRouter(prefix="/api/chat", tags=["Chat Assistant"])

class ChatRequest(BaseModel):
    user_id: int = 0
    user_name: str
    message: str
    disability_mode: str
    target_language: str = "en-IN"
    context: str = ""

class ChatResponse(BaseModel):
    reply: str

@router.post("/", response_model=ChatResponse)
async def chat_endpoint(req: ChatRequest):
    ai_reply = await get_ai_response(
        user_message=req.message,
        user_name=req.user_name,
        disability_mode=req.disability_mode,
        context=req.context,
        target_language=req.target_language,
    )

    # Persist chat to DB (non-blocking — ignore errors so chat still works)
    try:
        conn = get_conn()
        conn.execute(
            "INSERT INTO chat_history (user_id, message, reply) VALUES (?,?,?)",
            (req.user_id, req.message, ai_reply),
        )
        conn.commit()
        conn.close()
    except Exception:
        pass  # DB write failure should never break the chat response

    return ChatResponse(reply=ai_reply)


@router.get("/history/{user_id}", tags=["Chat Assistant"])
def get_chat_history(user_id: int, limit: int = 20):
    """Return recent chat history for a user (newest first)."""
    conn = get_conn()
    rows = conn.execute(
        "SELECT id, message, reply, created_at FROM chat_history "
        "WHERE user_id=? ORDER BY created_at DESC LIMIT ?",
        (user_id, limit),
    ).fetchall()
    conn.close()
    return {"history": [dict(r) for r in rows]}
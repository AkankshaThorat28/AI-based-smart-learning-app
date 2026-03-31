from fastapi import APIRouter
from pydantic import BaseModel
from learning_engine.milestone_logic import generate_quiz, evaluate_combined, create_manual_quiz
from learning_engine.report_gen import generate_progress_report
from database.db_config import get_conn

router = APIRouter()


@router.get("/manual-quiz")
def manual_quiz():
    """Return a hardcoded quiz with real MCQ structure for the frontend."""
    return create_manual_quiz()


@router.get("/ai-quiz")
def ai_quiz(topic: str = "Photosynthesis", level: int = 5):
    """Return an AI-difficulty-scaled quiz for the given topic."""
    return generate_quiz(topic, level)


@router.get("/evaluate")
def evaluate(teacher_score: int = 3, teacher_total: int = 5,
             ai_score: int = 2, ai_total: int = 3, pace: int = 5):
    return evaluate_combined(teacher_score, teacher_total, ai_score, ai_total, pace)


@router.get("/report")
def report(name: str = "Student", scores: str = "50,70,90"):
    score_list = [int(s) for s in scores.split(",")]
    return generate_progress_report(name, score_list)


class SubmitResult(BaseModel):
    user_id: int
    score: int
    total: int
    topic: str = "General"


@router.post("/submit-result")
def submit_result(req: SubmitResult):
    """Save a quiz result to the database."""
    try:
        conn = get_conn()
        conn.execute(
            "INSERT INTO quiz_results (user_id, score, total, topic) VALUES (?,?,?,?)",
            (req.user_id, req.score, req.total, req.topic),
        )
        conn.commit()
        conn.close()
        return {"status": "saved", "score": req.score, "total": req.total}
    except Exception as e:
        return {"status": "error", "detail": str(e)}


@router.get("/results/{user_id}")
def get_results(user_id: int):
    """Get all quiz results for a user."""
    conn = get_conn()
    rows = conn.execute(
        "SELECT * FROM quiz_results WHERE user_id=? ORDER BY created_at DESC",
        (user_id,),
    ).fetchall()
    conn.close()
    return {"results": [dict(r) for r in rows]}
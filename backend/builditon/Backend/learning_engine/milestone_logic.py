def generate_quiz(topic: str, current_pace_level: int):
    difficulty = "easy"

    if current_pace_level <= 3:
        difficulty = "very simple"
    elif current_pace_level <= 6:
        difficulty = "moderate"
    else:
        difficulty = "advanced"

    return {
        "topic": topic,
        "difficulty": difficulty,
        "message": "Quiz generated (dummy for now)"
    }


def evaluate_combined(
    teacher_score, teacher_total,
    ai_score, ai_total,
    current_pace_level
):
    teacher_percent = (teacher_score / teacher_total) * 100
    ai_percent = (ai_score / ai_total) * 100

    final_score = (0.6 * teacher_percent) + (0.4 * ai_percent)

    if final_score < 50:
        new_pace = max(1, current_pace_level - 1)
    elif final_score > 80:
        new_pace = min(10, current_pace_level + 1)
    else:
        new_pace = current_pace_level

    return {
        "final_score": final_score,
        "new_pace": new_pace
    }


def create_manual_quiz():
    return {
        "questions": [
            {
                "question": "What is photosynthesis?",
                "options": ["A process", "A machine", "A gas", "A mineral"],
                "answer": "A process"
            }
        ]
    }
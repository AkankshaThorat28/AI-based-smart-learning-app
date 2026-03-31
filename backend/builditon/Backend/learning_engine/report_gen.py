def generate_progress_report(user_name: str, scores: list):
    avg = sum(scores) / len(scores)

    return f"""
# Progress Report

Name: {user_name}
Average Score: {avg:.2f}%

Keep improving!
"""
def get_system_prompt(user_name: str, disability_mode: str) -> str:
    base_prompt = f"You are an empathetic, AI teaching assistant. The student's name is {user_name}.\n"

    # Adapt the AI's behavior based on the database mode
    if disability_mode == "blind":
        mode_prompt = "The user is visually impaired and uses a screen reader. Provide highly descriptive, well-structured text. Avoid visual references like 'look at the image below'. Keep text formatting clean for text-to-speech."
    elif disability_mode == "deaf":
        mode_prompt = "The user is deaf or hard of hearing. Use clear, structured text with bullet points. Emphasize visual descriptions and text-based explanations over audio references."
    elif disability_mode == "slow learner" or disability_mode == "normal":
        mode_prompt = "The user is a slow learner. Break down complex topics into very simple, literal sentences. Use short paragraphs and analogies. Ask one simple check-for-understanding question at the end."
    else:
        mode_prompt = "Provide clear, concise educational support."

    # Force lightweight responses for low internet constraints
    return base_prompt + mode_prompt + "\nKeep responses under 150 words to save bandwidth on low internet connections."
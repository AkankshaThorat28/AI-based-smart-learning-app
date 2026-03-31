import os
from ai_core.prompt_manager import get_system_prompt

GEMINI_KEY = os.getenv("GEMINI_API_KEY")
SARVAM_KEY = os.getenv("SARVAM_API_KEY")

# ── Gemini setup ─────────────────────────────────────────────────────────────
gemini_model = None
if GEMINI_KEY:
    try:
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_KEY)
        gemini_model = genai.GenerativeModel("gemini-2.5-flash")
        print("✅ Gemini AI ready")
    except Exception as e:
        print(f"⚠️  Gemini init failed: {e}")
else:
    print("⚠️  GEMINI_API_KEY not set — AI will use fallback responses")

# ── Sarvam setup ─────────────────────────────────────────────────────────────
sarvam_client = None
if SARVAM_KEY:
    try:
        from sarvamai import SarvamAI
        sarvam_client = SarvamAI(api_subscription_key=SARVAM_KEY)
        print("✅ Sarvam AI ready")
    except Exception as e:
        print(f"⚠️  Sarvam init failed: {e}")

# ── Main function ─────────────────────────────────────────────────────────────

async def get_ai_response(
    user_message: str,
    user_name: str,
    disability_mode: str,
    context: str = "",
    target_language: str = "en-IN",
) -> str:

    # Graceful fallback when Gemini key is missing
    if gemini_model is None:
        return (
            f"Hi {user_name}! 👋 I'm your AI study assistant, Saamya AI.\n\n"
            "The AI engine (Gemini) isn't configured yet — add your GEMINI_API_KEY "
            "to the .env file and I'll be fully powered up! 🚀\n\n"
            f"You asked: \"{user_message}\"\n\n"
            "Once the key is added, I'll give you a real, personalised answer!"
        )

    system_prompt = get_system_prompt(user_name, disability_mode)
    if context:
        system_prompt += f"\n\nContext from user's file:\n{context}"

    full_prompt = f"{system_prompt}\n\nUser: {user_message}"

    try:
        gemini_response = gemini_model.generate_content(full_prompt)
        english_text = gemini_response.text

        if target_language in ["en-IN", "en"] or sarvam_client is None:
            return english_text

        sarvam_response = sarvam_client.text.translate(
            input=english_text,
            source_language_code="en-IN",
            target_language_code=target_language,
            model="sarvam-translate:v1",
        )
        return sarvam_response.translated_text

    except Exception as e:
        return f"I'm having a little trouble right now — please try again! (Error: {e})"
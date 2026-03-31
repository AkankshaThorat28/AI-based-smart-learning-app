from dotenv import load_dotenv
load_dotenv()
import os

print("=== API KEY CHECK ===")
gemini = os.getenv("GEMINI_API_KEY","")
sarvam = os.getenv("SARVAM_API_KEY","")
sb_url = os.getenv("SUPABASE_URL","")
sb_key = os.getenv("SUPABASE_KEY","")

print("GEMINI  :", "FOUND" if gemini else "MISSING", gemini[:10] if gemini else "")
print("SARVAM  :", "FOUND" if sarvam else "MISSING", sarvam[:10] if sarvam else "")
print("SB_URL  :", "FOUND" if sb_url else "MISSING", sb_url)
print("SB_KEY  :", "FOUND" if sb_key else "MISSING", sb_key[:20] if sb_key else "")

print()
print("=== GEMINI TEST ===")
try:
    import google.generativeai as genai
    genai.configure(api_key=gemini)
    model = genai.GenerativeModel("gemini-2.5-flash")
    resp = model.generate_content("Say hello in one sentence.")
    print("OK:", resp.text[:100])
except Exception as e:
    print("ERROR:", e)

print()
print("=== SUPABASE TEST ===")
try:
    from supabase import create_client
    sb = create_client(sb_url, sb_key)
    print("OK: Supabase client created")
except Exception as e:
    print("ERROR:", e)

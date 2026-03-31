import os
from dotenv import load_dotenv
load_dotenv()
from supabase import create_client

url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_KEY")

print(f"URL: {url}")
print(f"KEY: {key[:20] if key else 'None'}")

if url and key:
    try:
        sb = create_client(url, key)
        res = sb.table('users').select('id').execute()
        print('Users table exists, rows:', len(res.data))
    except Exception as e:
        print('Supabase error:', e)
else:
    print('URL or KEY missing from env')

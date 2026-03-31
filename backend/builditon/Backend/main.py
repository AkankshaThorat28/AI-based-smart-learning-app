import os
from dotenv import load_dotenv

load_dotenv()

# Trigger reload
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import chat_routes, user_routes, doc_routes, test_routes

app = FastAPI(
    title="Saamya AI — Learning API",
    description="AI-powered accessible learning backend",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers — all under /api/* for clean separation
app.include_router(user_routes.router)                                      # /api/users/...
app.include_router(chat_routes.router)                                       # /api/chat/
app.include_router(doc_routes.router,  prefix="/api/docs",  tags=["Docs"])  # /api/docs/...
app.include_router(test_routes.router, prefix="/api/quiz",  tags=["Quiz"])  # /api/quiz/...

@app.get("/", tags=["Health"])
def root():
    from database.db_config import USE_SUPABASE
    return {
        "status": "✅ Backend is running!",
        "db": "supabase" if USE_SUPABASE else "sqlite (local)",
        "docs": "/docs",
    }
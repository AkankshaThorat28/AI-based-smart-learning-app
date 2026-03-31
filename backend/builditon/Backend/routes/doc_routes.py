from fastapi import APIRouter, UploadFile, File, HTTPException
import shutil
import os
from document_processing.rag_handler import extract_text_from_file, chunk_text

router = APIRouter()
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload_and_read")
async def upload_and_read(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    try:
        content = extract_text_from_file(file_path)
        chunks = chunk_text(content)
        return {
            "status": "success",
            "filename": file.filename, 
            "chunks": chunks[:2], 
            "total_chunks": len(chunks)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
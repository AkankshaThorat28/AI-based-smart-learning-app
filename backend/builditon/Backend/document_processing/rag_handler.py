import pdfplumber

def extract_text_from_file(file_path: str) -> str:
    """Extracts raw text from PDF or TXT files."""
    text = ""
    if file_path.endswith('.pdf'):
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                extracted = page.extract_text()
                if extracted:
                    text += extracted + "\n"
    elif file_path.endswith('.txt'):
        with open(file_path, 'r', encoding='utf-8') as f:
            text = f.read()
    return text

def chunk_text(text: str, chunk_size: int = 1000) -> list:
    """Splits text into 1000-char chunks for the LLM context."""
    return [text[i:i + chunk_size] for i in range(0, len(text), chunk_size)]
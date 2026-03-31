# Helper script to run the Saamya AI backend
# This script ensures the virtual environment is used and the app starts from the correct directory

Set-Location -Path "$PSScriptRoot/builditon/Backend"
$pythonPath = Join-Path $PSScriptRoot ".venv/Scripts/python.exe"

Write-Host "🚀 Starting Saamya AI Backend..." -ForegroundColor Green
& $pythonPath -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

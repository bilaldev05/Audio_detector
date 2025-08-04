from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or restrict to ["http://localhost:xxxx"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/analyze-voice/")
async def analyze_voice(file: UploadFile = File(...)):
    contents = await file.read()
    filename = f"temp_{file.filename}"
    with open(filename, "wb") as f:
        f.write(contents)

    # Mock detection: return "human" if file size is > 10KB else "robot"
    is_human = "human" if os.path.getsize(filename) > 10000 else "robot"

    os.remove(filename)
    return JSONResponse(content={"result": is_human})

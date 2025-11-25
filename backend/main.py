from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import query_latest_metrics

app = FastAPI()

# allow frontend react
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/latest")
def latest():
    return {
        "status": "ok",
        "data": query_latest_metrics(30)
    }


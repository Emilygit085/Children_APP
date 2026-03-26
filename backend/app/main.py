import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import activities, auth, bindings, chat, uploads, users, ws
from app.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Social App API", version="1.0.0")

if settings.cors_origins == "*":
    origins = ["*"]
else:
    origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(bindings.router, prefix="/api/v1")
app.include_router(activities.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")
app.include_router(uploads.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(ws.router)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}

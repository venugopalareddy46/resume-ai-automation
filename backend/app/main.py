import os
import socket

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models
from .database import engine, run_migrations
from .routers import (
    admin,
    auth_router,
    dashboard,
    export,
    history,
    resumes,
    settings,
    versions,
)

models.Base.metadata.create_all(bind=engine)
run_migrations()

app = FastAPI(
    title="AI Resume Tailor API",
    version=os.getenv("APP_VERSION", "1.1.0"),
)

_extra_origins = [
    o.strip()
    for o in os.getenv("CORS_ORIGINS", "").split(",")
    if o.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        *_extra_origins,
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(resumes.router)
app.include_router(versions.router)
app.include_router(export.router)
app.include_router(history.router)
app.include_router(settings.router)
app.include_router(dashboard.router)
app.include_router(admin.router)


@app.get("/")
def root():
    return {
        "status": "ok",
        "service": "resume-tailor-api",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": os.getenv("APP_NAME", "Resume AI"),
        "version": os.getenv("APP_VERSION", "1.1.0"),
        "environment": os.getenv("APP_ENV", "development"),
        "pod": socket.gethostname(),
    }
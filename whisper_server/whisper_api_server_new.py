"""
Whisper API Server - Refactored Version

A high-performance, production-ready FastAPI server that provides local Whisper
transcription with an OpenAI-compatible API interface.

This is the refactored version using modular services and dependency injection.
"""
import logging
import torch
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from config import WhisperConfig
from api.routes import router

# Configure logging
logging.basicConfig(
    level=getattr(logging, WhisperConfig.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Enable performance optimizations for PyTorch
torch.backends.cudnn.benchmark = True
torch.backends.cuda.matmul.allow_tf32 = True

# Create FastAPI application
app = FastAPI(
    title="Whisper API Server",
    description="Local Whisper API server with OpenAI-compatible interface",
    version="1.0.0",
)

# Validate configuration on startup
config_errors = WhisperConfig.validate_config()
if config_errors:
    logger.error("Configuration errors:")
    for error in config_errors:
        logger.error(f"  - {error}")
    raise RuntimeError("Invalid configuration")

# Add CORS middleware with secure configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=WhisperConfig.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["Content-Type", "Authorization"],
)

# Add trusted host middleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=WhisperConfig.ALLOWED_HOSTS,
)

# Include API routes
app.include_router(router)

# Startup event
@app.on_event("startup")
async def startup_event():
    """Log startup information."""
    logger.info(f"Starting Whisper API Server on {WhisperConfig.HOST}:{WhisperConfig.PORT}")
    logger.info(f"CORS origins: {WhisperConfig.ALLOWED_ORIGINS}")
    logger.info(f"Max audio file size: {WhisperConfig.MAX_AUDIO_FILE_SIZE_MB}MB")
    logger.info("Server started successfully")


# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Clean up resources on shutdown."""
    logger.info("Shutting down Whisper API Server")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,
        host=WhisperConfig.HOST,
        port=WhisperConfig.PORT,
        log_level=WhisperConfig.LOG_LEVEL.lower(),
    )

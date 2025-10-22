"""API routes for Whisper transcription server."""
import base64
import tempfile
import time
import logging
from pathlib import Path
from typing import Dict, Any
from fastapi import APIRouter, HTTPException, Request, Depends

from api.models import (
    TranscribeRequest,
    TranscribeResponse,
    HealthResponse,
    AudioInfoResponse,
)
from services.audio_processor import AudioProcessor, AudioProcessingError
from services.model_manager import ModelManager
from validators import validate_base64_audio, validate_model_name, validate_audio_format

logger = logging.getLogger(__name__)

# Create router
router = APIRouter()

# Global service instances (singleton pattern)
_model_manager: ModelManager = None
_audio_processor: AudioProcessor = None


def get_model_manager() -> ModelManager:
    """Dependency to get ModelManager instance."""
    global _model_manager
    if _model_manager is None:
        _model_manager = ModelManager(max_cache_size=4)
    return _model_manager


def get_audio_processor() -> AudioProcessor:
    """Dependency to get AudioProcessor instance."""
    global _audio_processor
    if _audio_processor is None:
        _audio_processor = AudioProcessor(
            target_sample_rate=16000,
            silence_threshold_db=40,
            normalize=True,
        )
    return _audio_processor


def detect_audio_extension(audio_bytes: bytes) -> str:
    """
    Detect audio file extension from bytes.

    Args:
        audio_bytes: Audio file bytes

    Returns:
        File extension (mp3, wav, etc.)
    """
    # Check file signatures (magic bytes)
    for signature, format_name in {
        b"\xff\xfb": "mp3",
        b"\xff\xf3": "mp3",
        b"\xff\xf2": "mp3",
        b"ID3": "mp3",
        b"ftyp": "m4a",
        b"moov": "m4a",
        b"mdat": "m4a",
        b"RIFF": "wav",
        b"fLaC": "flac",
        b"OggS": "ogg",
        b"\x1a\x45\xdf\xa3": "webm",
    }.items():
        if audio_bytes.startswith(signature):
            return format_name

    # Check for ID3 tag at different positions (MP3)
    if b"ID3" in audio_bytes[:128]:
        return "mp3"

    # Check for MP4 signatures at different positions
    if b"ftyp" in audio_bytes[:32] or b"moov" in audio_bytes[:32]:
        return "m4a"

    # Default to mp3 if unknown
    logger.warning("Could not detect audio format, using default: mp3")
    return "mp3"


@router.post("/v1/audio/transcriptions", response_model=TranscribeResponse)
async def transcribe(
    request: TranscribeRequest,
    client_request: Request,
    model_manager: ModelManager = Depends(get_model_manager),
    audio_processor: AudioProcessor = Depends(get_audio_processor),
) -> Dict[str, Any]:
    """
    Transcribe audio using local Whisper models.

    Args:
        request: Transcription request with audio data
        client_request: FastAPI request object
        model_manager: Model manager dependency
        audio_processor: Audio processor dependency

    Returns:
        Transcription response with text and metadata

    Raises:
        HTTPException: If validation or transcription fails
    """
    temp_file_path = None
    preprocessed_path = None

    try:
        # Log request for monitoring
        client_ip = client_request.client.host if client_request.client else "unknown"
        logger.info(f"Transcription request from {client_ip} with model {request.model}")

        # Validate model
        allowed_models = list(ModelManager.SUPPORTED_MODELS.keys())
        is_valid_model, model_error = validate_model_name(request.model, allowed_models)
        if not is_valid_model:
            raise HTTPException(status_code=400, detail=model_error)

        # Get and validate audio data
        try:
            audio_data = request.get_audio()
        except ValueError as e:
            logger.error("Invalid audio data format: %s", str(e))
            raise HTTPException(status_code=400, detail="Invalid audio data format")

        # Validate base64 audio
        is_valid_audio, audio_error = validate_base64_audio(audio_data)
        if not is_valid_audio:
            raise HTTPException(status_code=400, detail=audio_error)

        # Decode audio
        try:
            audio_bytes = base64.b64decode(audio_data)
        except Exception as e:
            logger.error(f"Failed to decode base64 audio: {str(e)}")
            raise HTTPException(status_code=400, detail="Invalid audio data format")

        # Validate audio format
        is_valid_format, format_error = validate_audio_format(audio_bytes)
        if not is_valid_format:
            raise HTTPException(status_code=400, detail=format_error)

        # Detect format for file extension
        file_extension = detect_audio_extension(audio_bytes)

        # Save to a temporary file with proper extension
        try:
            with tempfile.NamedTemporaryFile(
                delete=False, suffix=f".{file_extension}"
            ) as temp_file:
                temp_file.write(audio_bytes)
                temp_file_path = temp_file.name
        except Exception as e:
            logger.error(f"Failed to save temporary file: {str(e)}")
            raise HTTPException(status_code=500, detail="Failed to process audio file")

        # Preprocess audio for optimal performance
        try:
            preprocessed_path, success = audio_processor.preprocess(temp_file_path)
            if not success:
                logger.warning(f"Audio preprocessing failed, using original file")
        except AudioProcessingError as e:
            logger.error(f"Audio preprocessing error: {str(e)}")
            preprocessed_path = temp_file_path

        # Transcribe using local Whisper model
        try:
            start_time = time.time()

            # Get the model
            pipe, batch_size = model_manager.get_model(request.model)

            # Set language if specified (not "auto")
            language = request.language if request.language != "auto" else None

            logger.info(
                f"Transcribing with model {request.model}, format: {file_extension}"
            )

            # Perform transcription with optimized parameters
            result = pipe(
                preprocessed_path,
                batch_size=batch_size,
                return_timestamps=True,
                generate_kwargs={
                    "language": language,
                    "do_sample": False,  # Deterministic for speed
                    "num_beams": 1,  # Greedy decoding for speed
                },
            )

            processing_time = time.time() - start_time

            # Extract text from result
            if isinstance(result, dict):
                text = result.get("text", "")
            elif isinstance(result, list) and len(result) > 0:
                text = result[0].get("text", "")
            else:
                text = str(result)

            logger.info(f"Transcription completed in {processing_time:.2f}s")

            return {
                "text": text,
                "processing_time": processing_time,
                "model": request.model,
                "format": file_extension,
            }

        except Exception as e:
            logger.error(f"Transcription failed: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")

    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        # Clean up temporary files
        for file_path in [temp_file_path, preprocessed_path]:
            if file_path and Path(file_path).exists() and file_path != temp_file_path:
                try:
                    Path(file_path).unlink()
                except Exception as e:
                    logger.warning(f"Failed to clean up temporary file {file_path}: {str(e)}")


@router.post("/v1/chat/completions", response_model=TranscribeResponse)
async def chat_completions(
    request: TranscribeRequest,
    client_request: Request,
    model_manager: ModelManager = Depends(get_model_manager),
    audio_processor: AudioProcessor = Depends(get_audio_processor),
) -> Dict[str, Any]:
    """OpenAI-style compatibility endpoint that proxies to /v1/audio/transcriptions."""
    return await transcribe(request, client_request, model_manager, audio_processor)


@router.get("/health", response_model=HealthResponse)
async def health_check() -> Dict[str, str]:
    """Health check endpoint."""
    return {"status": "healthy", "service": "whisper-api-server"}


@router.post("/debug/audio-info", response_model=AudioInfoResponse)
async def debug_audio_info(request: TranscribeRequest) -> Dict[str, Any]:
    """Debug endpoint to get information about audio data without transcribing."""
    try:
        audio_data = request.get_audio()
        audio_bytes = base64.b64decode(audio_data)

        return {
            "audio_size_bytes": len(audio_bytes),
            "audio_size_mb": len(audio_bytes) / (1024 * 1024),
            "base64_length": len(audio_data),
            "model": request.model,
            "language": request.language,
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

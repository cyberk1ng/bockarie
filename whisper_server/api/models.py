"""Pydantic models for API requests and responses."""
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from config import WhisperConfig


class TranscribeRequest(BaseModel):
    """Request model for transcription endpoint."""

    audio: Optional[str] = None
    model: str = WhisperConfig.DEFAULT_MODEL
    language: Optional[str] = "auto"
    messages: Optional[List[Dict[str, Any]]] = None
    audio_options: Optional[Dict[str, Any]] = None

    def get_audio(self) -> str:
        """
        Extract audio data from various possible locations in the request.

        Returns:
            Base64-encoded audio data

        Raises:
            ValueError: If no audio data found in request
        """
        if self.audio:
            return self.audio
        if self.audio_options and "data" in self.audio_options:
            return self.audio_options["data"]
        if self.messages:
            for msg in self.messages:
                audio_data = self._extract_audio_from_message(msg)
                if audio_data:
                    return audio_data
        raise ValueError("No audio data found in request")

    def _extract_audio_from_message(self, msg: dict) -> Optional[str]:
        """
        Extract audio from a message object.

        Args:
            msg: Message dictionary

        Returns:
            Base64-encoded audio data or None
        """
        content = msg.get("content")
        if isinstance(content, list):
            for part in content:
                if part.get("type") in ["audio", "input_audio"]:
                    if "inputAudio" in part and "data" in part["inputAudio"]:
                        return part["inputAudio"]["data"]
                    elif "data" in part:
                        return part["data"]
        elif isinstance(content, dict):
            if "data" in content:
                return content["data"]
            elif "format" in content and "data" in content:
                return content["data"]
        return None


class TranscribeResponse(BaseModel):
    """Response model for transcription endpoint."""

    text: str
    processing_time: float
    model: str
    format: str


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""

    status: str
    service: str


class AudioInfoResponse(BaseModel):
    """Response model for debug audio info endpoint."""

    audio_size_bytes: int
    audio_size_mb: float
    base64_length: int
    model: str
    language: Optional[str]

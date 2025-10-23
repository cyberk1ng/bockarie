"""Pytest configuration and shared fixtures."""
import base64
import pytest
import tempfile
from pathlib import Path
from typing import Generator


@pytest.fixture
def sample_audio_base64() -> str:
    """
    Return a small valid base64-encoded MP3 audio file.

    This is a minimal MP3 file that's valid enough for testing.
    """
    # Minimal valid MP3 header + data (about 2KB)
    mp3_data = (
        b'\xff\xfb\x90\x00' + b'\x00' * 2000  # MP3 header + padding
    )
    return base64.b64encode(mp3_data).decode('utf-8')


@pytest.fixture
def large_audio_base64() -> str:
    """Return base64-encoded audio larger than max size."""
    # Create 15MB of data (larger than 10MB default max)
    large_data = b'\xff\xfb\x90\x00' + b'\x00' * (15 * 1024 * 1024)
    return base64.b64encode(large_data).decode('utf-8')


@pytest.fixture
def invalid_base64() -> str:
    """Return invalid base64 string."""
    return "This is not valid base64!!!"


@pytest.fixture
def sample_wav_bytes() -> bytes:
    """Return minimal WAV file bytes."""
    # Minimal WAV header
    return b'RIFF' + b'\x00' * 100


@pytest.fixture
def sample_mp3_bytes() -> bytes:
    """Return minimal MP3 file bytes."""
    return b'\xff\xfb' + b'\x00' * 100


@pytest.fixture
def sample_mp4_bytes() -> bytes:
    """Return minimal MP4 file bytes."""
    return b'ftyp' + b'\x00' * 100


@pytest.fixture
def temp_audio_file() -> Generator[Path, None, None]:
    """Create a temporary audio file for testing."""
    with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as f:
        # Write minimal valid MP3 data
        f.write(b'\xff\xfb\x90\x00' + b'\x00' * 2000)
        temp_path = Path(f.name)

    yield temp_path

    # Cleanup
    if temp_path.exists():
        temp_path.unlink()


@pytest.fixture
def mock_env_vars(monkeypatch):
    """Set up mock environment variables for testing."""
    monkeypatch.setenv("WHISPER_SERVER_HOST", "127.0.0.1")
    monkeypatch.setenv("WHISPER_SERVER_PORT", "8089")
    monkeypatch.setenv("MAX_AUDIO_FILE_SIZE_MB", "10")
    monkeypatch.setenv("LOG_LEVEL", "INFO")
    monkeypatch.setenv("ALLOWED_ORIGINS", "http://localhost:3000")
    monkeypatch.setenv("ALLOWED_HOSTS", "*")

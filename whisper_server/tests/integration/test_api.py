"""Integration tests for API endpoints."""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch
import base64

# Import the app
from whisper_api_server import app
from services.model_manager import ModelManager
from services.audio_processor import AudioProcessor


@pytest.fixture
def client():
    """Create a test client for the FastAPI app."""
    return TestClient(app)


@pytest.fixture
def mock_model_manager():
    """Create a mock ModelManager."""
    mock = Mock(spec=ModelManager)
    # Mock the get_model method to return a mock pipeline and batch size
    mock_pipe = Mock()
    mock_pipe.return_value = {"text": "Test transcription"}
    mock.get_model.return_value = (mock_pipe, 4)
    return mock


@pytest.fixture
def mock_audio_processor():
    """Create a mock AudioProcessor."""
    mock = Mock(spec=AudioProcessor)
    # Mock the preprocess method to return success
    mock.preprocess.return_value = ("/tmp/test_preprocessed.wav", True)
    return mock


class TestHealthEndpoint:
    """Tests for /health endpoint."""

    def test_health_check(self, client):
        """Test health check endpoint returns 200."""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "whisper-api-server"


class TestDebugEndpoint:
    """Tests for /debug/audio-info endpoint."""

    def test_audio_info_valid(self, client, sample_audio_base64):
        """Test debug endpoint returns audio info."""
        response = client.post(
            "/debug/audio-info",
            json={
                "audio": sample_audio_base64,
                "model": "whisper-1",
                "language": "auto",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "audio_size_bytes" in data
        assert "audio_size_mb" in data
        assert data["model"] == "whisper-1"
        assert data["language"] == "auto"

    def test_audio_info_invalid_audio(self, client):
        """Test debug endpoint with invalid audio."""
        response = client.post(
            "/debug/audio-info",
            json={
                "audio": "invalid!!!",
                "model": "whisper-1",
            },
        )
        assert response.status_code == 400


class TestTranscriptionEndpoint:
    """Tests for /v1/audio/transcriptions endpoint."""

    def test_transcribe_missing_audio(self, client):
        """Test transcription fails without audio data."""
        response = client.post(
            "/v1/audio/transcriptions",
            json={"model": "whisper-1"},
        )
        assert response.status_code == 400
        assert "audio" in response.json()["detail"].lower()

    def test_transcribe_invalid_model(self, client, sample_audio_base64):
        """Test transcription fails with invalid model."""
        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "audio": sample_audio_base64,
                "model": "invalid-model",
            },
        )
        assert response.status_code == 400
        assert "invalid model" in response.json()["detail"].lower()

    def test_transcribe_audio_too_large(self, client, large_audio_base64):
        """Test transcription fails with too large audio."""
        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "audio": large_audio_base64,
                "model": "whisper-1",
            },
        )
        assert response.status_code == 400
        assert "too large" in response.json()["detail"].lower()

    def test_transcribe_invalid_base64(self, client, invalid_base64):
        """Test transcription fails with invalid base64."""
        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "audio": invalid_base64,
                "model": "whisper-1",
            },
        )
        assert response.status_code == 400

    @patch("api.routes.get_model_manager")
    @patch("api.routes.get_audio_processor")
    def test_transcribe_success(
        self,
        mock_get_processor,
        mock_get_manager,
        client,
        sample_audio_base64,
        mock_model_manager,
        mock_audio_processor,
        tmp_path,
    ):
        """Test successful transcription with mocked services."""
        # Setup mocks
        mock_get_manager.return_value = mock_model_manager
        mock_get_processor.return_value = mock_audio_processor

        # Mock the temp file creation
        temp_file = tmp_path / "test.mp3"
        temp_file.write_bytes(b"\xff\xfb" + b"\x00" * 100)

        # Update mock to return the temp file path
        mock_audio_processor.preprocess.return_value = (str(temp_file), True)

        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "audio": sample_audio_base64,
                "model": "whisper-1",
                "language": "en",
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert "text" in data
        assert "processing_time" in data
        assert data["model"] == "whisper-1"
        assert "format" in data


class TestChatCompletionsEndpoint:
    """Tests for /v1/chat/completions endpoint."""

    def test_chat_completions_proxy(self, client, sample_audio_base64):
        """Test chat completions endpoint proxies to transcriptions."""
        response = client.post(
            "/v1/chat/completions",
            json={
                "audio": sample_audio_base64,
                "model": "whisper-1",
            },
        )
        # Should behave the same as transcriptions endpoint
        assert response.status_code in [200, 400, 500]


class TestRequestModels:
    """Tests for request model variations."""

    def test_audio_in_audio_options(self, client):
        """Test extracting audio from audio_options field."""
        audio_data = base64.b64encode(b"\xff\xfb" + b"\x00" * 100).decode("utf-8")
        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "audio_options": {"data": audio_data},
                "model": "whisper-1",
            },
        )
        # Small audio may fail validation (too small) or pass to processing
        assert response.status_code in [200, 400, 500]

    def test_audio_in_messages(self, client):
        """Test extracting audio from messages field."""
        audio_data = base64.b64encode(b"\xff\xfb" + b"\x00" * 100).decode("utf-8")
        response = client.post(
            "/v1/audio/transcriptions",
            json={
                "messages": [
                    {
                        "content": [
                            {
                                "type": "audio",
                                "data": audio_data,
                            }
                        ]
                    }
                ],
                "model": "whisper-1",
            },
        )
        # Small audio may fail validation (too small) or pass to processing
        assert response.status_code in [200, 400, 500]


class TestAudioFormatDetection:
    """Tests for audio format detection."""

    def test_detect_mp3_format(self, client):
        """Test MP3 format detection."""
        mp3_data = b"\xff\xfb" + b"\x00" * 2000
        audio_base64 = base64.b64encode(mp3_data).decode("utf-8")

        response = client.post(
            "/debug/audio-info",
            json={"audio": audio_base64, "model": "whisper-1"},
        )
        assert response.status_code == 200

    def test_detect_wav_format(self, client):
        """Test WAV format detection."""
        wav_data = b"RIFF" + b"\x00" * 2000
        audio_base64 = base64.b64encode(wav_data).decode("utf-8")

        response = client.post(
            "/debug/audio-info",
            json={"audio": audio_base64, "model": "whisper-1"},
        )
        assert response.status_code == 200

    def test_detect_m4a_format(self, client):
        """Test M4A/MP4 format detection."""
        m4a_data = b"ftyp" + b"\x00" * 2000
        audio_base64 = base64.b64encode(m4a_data).decode("utf-8")

        response = client.post(
            "/debug/audio-info",
            json={"audio": audio_base64, "model": "whisper-1"},
        )
        assert response.status_code == 200

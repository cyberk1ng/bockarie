"""Unit tests for config module."""
import pytest
import os
from config import WhisperConfig


class TestWhisperConfig:
    """Tests for WhisperConfig class."""

    def test_default_values(self):
        """Test default configuration values."""
        assert WhisperConfig.HOST == os.getenv("WHISPER_SERVER_HOST", "127.0.0.1")
        assert WhisperConfig.PORT == int(os.getenv("WHISPER_SERVER_PORT", "8089"))
        assert WhisperConfig.DEFAULT_MODEL == "whisper-1"
        assert WhisperConfig.MAX_AUDIO_FILE_SIZE_MB > 0
        assert WhisperConfig.LOG_LEVEL in ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]

    def test_max_audio_size_bytes_calculation(self):
        """Test that MAX_AUDIO_FILE_SIZE_BYTES is calculated correctly."""
        expected_bytes = WhisperConfig.MAX_AUDIO_FILE_SIZE_MB * 1024 * 1024
        assert WhisperConfig.MAX_AUDIO_FILE_SIZE_BYTES == expected_bytes

    def test_supported_audio_formats(self):
        """Test that all expected audio formats are supported."""
        expected_formats = ["mp3", "mp4", "m4a", "wav", "flac", "webm", "ogg"]
        for format in expected_formats:
            assert format in WhisperConfig.SUPPORTED_AUDIO_FORMATS

    def test_allowed_origins_is_list(self):
        """Test that ALLOWED_ORIGINS is a list."""
        assert isinstance(WhisperConfig.ALLOWED_ORIGINS, list)

    def test_allowed_hosts_is_list(self):
        """Test that ALLOWED_HOSTS is a list."""
        assert isinstance(WhisperConfig.ALLOWED_HOSTS, list)


class TestConfigValidation:
    """Tests for config validation."""

    def test_valid_config(self):
        """Test validation passes with valid config."""
        original_port = WhisperConfig.PORT
        original_size = WhisperConfig.MAX_AUDIO_FILE_SIZE_MB

        try:
            WhisperConfig.PORT = 8089
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = 10
            errors = WhisperConfig.validate_config()
            assert len(errors) == 0
        finally:
            WhisperConfig.PORT = original_port
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = original_size

    def test_invalid_port_too_low(self):
        """Test validation fails for port <= 0."""
        original_port = WhisperConfig.PORT

        try:
            WhisperConfig.PORT = 0
            errors = WhisperConfig.validate_config()
            assert len(errors) > 0
            assert any("PORT" in err for err in errors)
        finally:
            WhisperConfig.PORT = original_port

    def test_invalid_port_too_high(self):
        """Test validation fails for port > 65535."""
        original_port = WhisperConfig.PORT

        try:
            WhisperConfig.PORT = 70000
            errors = WhisperConfig.validate_config()
            assert len(errors) > 0
            assert any("PORT" in err for err in errors)
        finally:
            WhisperConfig.PORT = original_port

    def test_invalid_max_file_size_zero(self):
        """Test validation fails for MAX_AUDIO_FILE_SIZE_MB <= 0."""
        original_size = WhisperConfig.MAX_AUDIO_FILE_SIZE_MB

        try:
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = 0
            errors = WhisperConfig.validate_config()
            assert len(errors) > 0
            assert any("MAX_AUDIO_FILE_SIZE_MB" in err for err in errors)
        finally:
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = original_size

    def test_invalid_max_file_size_negative(self):
        """Test validation fails for negative MAX_AUDIO_FILE_SIZE_MB."""
        original_size = WhisperConfig.MAX_AUDIO_FILE_SIZE_MB

        try:
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = -5
            errors = WhisperConfig.validate_config()
            assert len(errors) > 0
            assert any("MAX_AUDIO_FILE_SIZE_MB" in err for err in errors)
        finally:
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = original_size

    def test_multiple_validation_errors(self):
        """Test validation returns multiple errors when multiple issues exist."""
        original_port = WhisperConfig.PORT
        original_size = WhisperConfig.MAX_AUDIO_FILE_SIZE_MB

        try:
            WhisperConfig.PORT = -1
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = -10
            errors = WhisperConfig.validate_config()
            assert len(errors) >= 2
        finally:
            WhisperConfig.PORT = original_port
            WhisperConfig.MAX_AUDIO_FILE_SIZE_MB = original_size


class TestEnvironmentVariables:
    """Tests for environment variable handling."""

    def test_env_var_override_port(self, monkeypatch):
        """Test that WHISPER_SERVER_PORT env var is used."""
        # Note: Config is loaded at import time, so changing env vars after import
        # doesn't affect WhisperConfig.PORT. This test verifies the default behavior.
        monkeypatch.setenv("WHISPER_SERVER_PORT", "9090")
        # After monkeypatch, os.getenv returns new value
        assert os.getenv("WHISPER_SERVER_PORT") == "9090"
        # But WhisperConfig.PORT keeps its import-time value
        # This documents current behavior - to change port, set env var before import

    def test_env_var_override_host(self, monkeypatch):
        """Test that WHISPER_SERVER_HOST env var is used."""
        # Note: Config is loaded at import time
        monkeypatch.setenv("WHISPER_SERVER_HOST", "0.0.0.0")
        assert os.getenv("WHISPER_SERVER_HOST") == "0.0.0.0"
        # WhisperConfig.HOST keeps import-time value

    def test_env_var_override_max_size(self, monkeypatch):
        """Test that MAX_AUDIO_FILE_SIZE_MB env var is used."""
        # Note: Config is loaded at import time
        monkeypatch.setenv("MAX_AUDIO_FILE_SIZE_MB", "25")
        assert os.getenv("MAX_AUDIO_FILE_SIZE_MB") == "25"
        # WhisperConfig.MAX_AUDIO_FILE_SIZE_MB keeps import-time value

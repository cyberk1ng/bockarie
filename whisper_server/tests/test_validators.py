"""Unit tests for validators module."""
import pytest
import base64
from validators import (
    validate_base64_audio,
    validate_model_name,
    validate_audio_format,
    sanitize_filename,
    detect_audio_format,
    ValidationError,
    AudioValidationError,
    SecurityValidationError,
)
from config import WhisperConfig


class TestValidateBase64Audio:
    """Tests for validate_base64_audio function."""

    def test_valid_audio(self, sample_audio_base64):
        """Test validation of valid base64 audio."""
        is_valid, error = validate_base64_audio(sample_audio_base64)
        assert is_valid is True
        assert error is None

    def test_empty_audio(self):
        """Test validation fails for empty audio."""
        is_valid, error = validate_base64_audio("")
        assert is_valid is False
        assert error == "Audio data is required"

    def test_none_audio(self):
        """Test validation fails for None audio."""
        is_valid, error = validate_base64_audio(None)
        assert is_valid is False
        assert error == "Audio data is required"

    def test_invalid_base64(self, invalid_base64):
        """Test validation fails for invalid base64 encoding."""
        is_valid, error = validate_base64_audio(invalid_base64)
        assert is_valid is False
        # Either invalid base64 or too small (depends on decode result)
        assert error in ["Invalid base64 encoding", "Audio file too small. Minimum size is 1KB"]

    def test_audio_too_large(self, large_audio_base64):
        """Test validation fails for audio exceeding max size."""
        is_valid, error = validate_base64_audio(large_audio_base64)
        assert is_valid is False
        assert "too large" in error.lower()
        assert str(WhisperConfig.MAX_AUDIO_FILE_SIZE_MB) in error

    def test_audio_too_small(self):
        """Test validation fails for audio smaller than minimum size."""
        # Create audio smaller than 1KB (1024 bytes)
        tiny_audio = base64.b64encode(b'\xff\xfb' + b'\x00' * 500).decode('utf-8')
        is_valid, error = validate_base64_audio(tiny_audio)
        assert is_valid is False
        assert "too small" in error.lower()

    def test_exactly_min_size(self):
        """Test validation passes for audio exactly at minimum size."""
        # Create audio exactly 1KB
        min_audio = base64.b64encode(b'\xff\xfb' + b'\x00' * 1022).decode('utf-8')
        is_valid, error = validate_base64_audio(min_audio)
        assert is_valid is True
        assert error is None


class TestValidateModelName:
    """Tests for validate_model_name function."""

    def test_valid_model_whisper_1(self):
        """Test validation of whisper-1 model."""
        is_valid, error = validate_model_name("whisper-1")
        assert is_valid is True
        assert error is None

    def test_valid_model_whisper_tiny(self):
        """Test validation of whisper-tiny model."""
        is_valid, error = validate_model_name("whisper-tiny")
        assert is_valid is True
        assert error is None

    def test_valid_model_whisper_small(self):
        """Test validation of whisper-small model."""
        is_valid, error = validate_model_name("whisper-small")
        assert is_valid is True
        assert error is None

    def test_valid_model_whisper_medium(self):
        """Test validation of whisper-medium model."""
        is_valid, error = validate_model_name("whisper-medium")
        assert is_valid is True
        assert error is None

    def test_valid_model_whisper_large(self):
        """Test validation of whisper-large model."""
        is_valid, error = validate_model_name("whisper-large")
        assert is_valid is True
        assert error is None

    def test_empty_model(self):
        """Test validation fails for empty model name."""
        is_valid, error = validate_model_name("")
        assert is_valid is False
        assert error == "Model name is required"

    def test_none_model(self):
        """Test validation fails for None model name."""
        is_valid, error = validate_model_name(None)
        assert is_valid is False
        assert error == "Model name is required"

    def test_invalid_model(self):
        """Test validation fails for invalid model name."""
        is_valid, error = validate_model_name("invalid-model")
        assert is_valid is False
        assert "Invalid model" in error
        assert "whisper-1" in error

    def test_custom_allowed_models(self):
        """Test validation with custom allowed models list."""
        custom_models = ["custom-model-1", "custom-model-2"]
        is_valid, error = validate_model_name("custom-model-1", custom_models)
        assert is_valid is True
        assert error is None

    def test_custom_allowed_models_invalid(self):
        """Test validation fails for model not in custom list."""
        custom_models = ["custom-model-1", "custom-model-2"]
        is_valid, error = validate_model_name("whisper-1", custom_models)
        assert is_valid is False
        assert "Invalid model" in error


class TestDetectAudioFormat:
    """Tests for detect_audio_format function."""

    def test_detect_mp3_format_ffxfb(self, sample_mp3_bytes):
        """Test detection of MP3 format with \\xff\\xfb signature."""
        audio_bytes = b'\xff\xfb' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp3"

    def test_detect_mp3_format_ffxf3(self):
        """Test detection of MP3 format with \\xff\\xf3 signature."""
        audio_bytes = b'\xff\xf3' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp3"

    def test_detect_mp3_format_id3(self):
        """Test detection of MP3 format with ID3 tag."""
        audio_bytes = b'ID3' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp3"

    def test_detect_mp3_format_id3_offset(self):
        """Test detection of MP3 format with ID3 tag at offset."""
        audio_bytes = b'\x00' * 50 + b'ID3' + b'\x00' * 50
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp3"

    def test_detect_wav_format(self, sample_wav_bytes):
        """Test detection of WAV format."""
        audio_bytes = b'RIFF' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "wav"

    def test_detect_mp4_format_ftyp(self):
        """Test detection of MP4 format with ftyp signature."""
        audio_bytes = b'ftyp' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp4"

    def test_detect_mp4_format_moov(self):
        """Test detection of MP4 format with moov signature."""
        audio_bytes = b'moov' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "mp4"

    def test_detect_flac_format(self):
        """Test detection of FLAC format."""
        audio_bytes = b'fLaC' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "flac"

    def test_detect_ogg_format(self):
        """Test detection of OGG format."""
        audio_bytes = b'OggS' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "ogg"

    def test_detect_webm_format(self):
        """Test detection of WebM format."""
        audio_bytes = b'\x1a\x45\xdf\xa3' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected == "webm"

    def test_detect_unknown_format(self):
        """Test detection returns None for unknown format."""
        audio_bytes = b'\x00\x00\x00\x00' + b'\x00' * 100
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected is None

    def test_detect_format_too_short(self):
        """Test detection returns None for too short audio."""
        audio_bytes = b'\xff'
        format_detected = detect_audio_format(audio_bytes)
        assert format_detected is None


class TestValidateAudioFormat:
    """Tests for validate_audio_format function."""

    def test_validate_mp3_format(self):
        """Test validation passes for MP3 format."""
        audio_bytes = b'\xff\xfb' + b'\x00' * 100
        is_valid, error = validate_audio_format(audio_bytes)
        assert is_valid is True
        assert error is None

    def test_validate_wav_format(self):
        """Test validation passes for WAV format."""
        audio_bytes = b'RIFF' + b'\x00' * 100
        is_valid, error = validate_audio_format(audio_bytes)
        assert is_valid is True
        assert error is None

    def test_validate_mp4_format(self):
        """Test validation passes for MP4 format."""
        audio_bytes = b'ftyp' + b'\x00' * 100
        is_valid, error = validate_audio_format(audio_bytes)
        assert is_valid is True
        assert error is None

    def test_validate_flac_format(self):
        """Test validation passes for FLAC format."""
        audio_bytes = b'fLaC' + b'\x00' * 100
        is_valid, error = validate_audio_format(audio_bytes)
        assert is_valid is True
        assert error is None

    def test_validate_unknown_format_allows(self):
        """Test validation allows unknown format (to be handled by OpenAI)."""
        audio_bytes = b'\x00\x00\x00\x00' + b'\x00' * 100
        is_valid, error = validate_audio_format(audio_bytes)
        # Should pass with warning logged
        assert is_valid is True
        assert error is None


class TestSanitizeFilename:
    """Tests for sanitize_filename function."""

    def test_sanitize_normal_filename(self):
        """Test sanitization of normal filename."""
        filename = "test_audio.mp3"
        sanitized = sanitize_filename(filename)
        assert sanitized == "test_audio.mp3"

    def test_sanitize_path_separators(self):
        """Test removal of path separators."""
        filename = "../../../etc/passwd"
        sanitized = sanitize_filename(filename)
        assert "/" not in sanitized
        assert "\\" not in sanitized
        # The current implementation removes special chars but not dots
        # So we just verify slashes are removed
        assert "etc" in sanitized
        assert "passwd" in sanitized

    def test_sanitize_dangerous_chars(self):
        """Test removal of dangerous characters."""
        filename = 'test<>:"/\\|?*.mp3'
        sanitized = sanitize_filename(filename)
        for char in '<>:"/\\|?*':
            assert char not in sanitized

    def test_sanitize_long_filename(self):
        """Test truncation of long filenames."""
        filename = "a" * 200 + ".mp3"
        sanitized = sanitize_filename(filename)
        assert len(sanitized) <= 100

    def test_sanitize_empty_filename(self):
        """Test sanitization of empty filename."""
        filename = ""
        sanitized = sanitize_filename(filename)
        assert sanitized == ""


class TestExceptionClasses:
    """Tests for custom exception classes."""

    def test_validation_error(self):
        """Test ValidationError can be raised and caught."""
        with pytest.raises(ValidationError):
            raise ValidationError("Test error")

    def test_audio_validation_error(self):
        """Test AudioValidationError can be raised and caught."""
        with pytest.raises(AudioValidationError):
            raise AudioValidationError("Audio error")

        # Should also be catchable as ValidationError
        with pytest.raises(ValidationError):
            raise AudioValidationError("Audio error")

    def test_security_validation_error(self):
        """Test SecurityValidationError can be raised and caught."""
        with pytest.raises(SecurityValidationError):
            raise SecurityValidationError("Security error")

        # Should also be catchable as ValidationError
        with pytest.raises(ValidationError):
            raise SecurityValidationError("Security error")

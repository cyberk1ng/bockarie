"""Audio preprocessing service for optimal Whisper performance."""
import logging
from pathlib import Path
from typing import Tuple
import librosa
import soundfile as sf
import numpy as np

logger = logging.getLogger(__name__)


class AudioProcessingError(Exception):
    """Raised when audio preprocessing fails."""
    pass


class AudioProcessor:
    """
    Service for preprocessing audio files for optimal Whisper transcription.

    Handles resampling, normalization, and silence trimming.
    """

    def __init__(
        self,
        target_sample_rate: int = 16000,
        silence_threshold_db: int = 40,
        normalize: bool = True,
    ):
        """
        Initialize AudioProcessor.

        Args:
            target_sample_rate: Target sample rate for Whisper (default: 16000Hz)
            silence_threshold_db: Threshold in dB for silence trimming (default: 40)
            normalize: Whether to normalize audio (default: True)
        """
        self.target_sample_rate = target_sample_rate
        self.silence_threshold_db = silence_threshold_db
        self.normalize = normalize

    def preprocess(self, audio_path: str) -> Tuple[str, bool]:
        """
        Preprocess audio file for optimal Whisper performance.

        Args:
            audio_path: Path to the audio file

        Returns:
            Tuple of (preprocessed_path, preprocessing_succeeded)

        Raises:
            AudioProcessingError: If preprocessing fails unexpectedly
        """
        try:
            # Load audio with explicit format handling and suppress warnings
            import warnings

            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                audio, sr = librosa.load(audio_path, sr=None, mono=True)

            logger.info(
                f"Loaded audio: {len(audio)} samples at {sr}Hz, duration: {len(audio)/sr:.2f}s"
            )

            # Resample to 16kHz (Whisper's optimal sample rate)
            if sr != self.target_sample_rate:
                audio = librosa.resample(
                    audio, orig_sr=sr, target_sr=self.target_sample_rate
                )
                logger.info(f"Resampled to {self.target_sample_rate}Hz: {len(audio)} samples")

            # Normalize audio
            if self.normalize:
                audio = librosa.util.normalize(audio)

            # Trim silence (use configured threshold for voice)
            audio_before_trim = len(audio)
            audio, _ = librosa.effects.trim(audio, top_db=self.silence_threshold_db)
            logger.info(
                f"Trimmed audio: {audio_before_trim} -> {len(audio)} samples "
                f"(kept {len(audio)/audio_before_trim*100:.1f}%)"
            )

            # Save preprocessed audio as WAV (most compatible format)
            preprocessed_path = audio_path.replace(".", "_preprocessed.wav")
            sf.write(preprocessed_path, audio, self.target_sample_rate, format="WAV")

            logger.info(
                f"Preprocessed audio saved: {preprocessed_path}, "
                f"duration: {len(audio)/self.target_sample_rate:.2f}s"
            )
            return preprocessed_path, True

        except (librosa.LibrosaError, sf.SoundFileError) as e:
            logger.warning(
                f"Audio preprocessing failed: {str(e)}, using original file",
                extra={"audio_path": audio_path, "error_type": type(e).__name__},
            )
            return audio_path, False

        except Exception as e:
            logger.error(
                f"Unexpected error in audio preprocessing: {str(e)}",
                exc_info=True,
                extra={"audio_path": audio_path},
            )
            # Re-raise unexpected errors
            raise AudioProcessingError(f"Failed to preprocess audio: {str(e)}") from e

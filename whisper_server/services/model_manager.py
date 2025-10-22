"""Model management service for loading and caching Whisper models."""
import logging
import threading
from typing import Dict, Tuple, Optional
import torch
from transformers import pipeline, BitsAndBytesConfig

logger = logging.getLogger(__name__)


class ModelManager:
    """
    Thread-safe model manager with caching and hardware optimization.

    Handles loading Whisper models with appropriate optimizations based on
    available hardware (CUDA, MPS, CPU).
    """

    # Supported models mapping
    SUPPORTED_MODELS = {
        "whisper-1": "openai/whisper-large-v3",
        "whisper-tiny": "openai/whisper-tiny",
        "whisper-small": "openai/whisper-small",
        "whisper-medium": "openai/whisper-medium",
        "whisper-large": "openai/whisper-large-v3",
    }

    def __init__(self, max_cache_size: int = 4):
        """
        Initialize ModelManager.

        Args:
            max_cache_size: Maximum number of models to cache (default: 4)
        """
        self._models: Dict[str, Tuple] = {}
        self._lock = threading.RLock()
        self._max_cache_size = max_cache_size
        self._device = self._get_optimal_device()
        self._batch_size = self._get_optimal_batch_size(self._device)

        logger.info(f"ModelManager initialized with device: {self._device}")

    def get_model(self, model_name: str) -> Tuple:
        """
        Get or load a model (thread-safe).

        Args:
            model_name: Name of the model to load

        Returns:
            Tuple of (pipeline, batch_size)

        Raises:
            ValueError: If model_name is not supported
        """
        if model_name not in self.SUPPORTED_MODELS:
            raise ValueError(
                f"Unsupported model: {model_name}. "
                f"Supported models: {list(self.SUPPORTED_MODELS.keys())}"
            )

        with self._lock:
            if model_name in self._models:
                logger.debug(f"Model {model_name} found in cache")
                return self._models[model_name]

            # Load model
            logger.info(f"Loading model {model_name}...")
            pipe, batch_size = self._load_model(model_name)

            # Cache eviction if needed (LRU-style)
            if len(self._models) >= self._max_cache_size:
                oldest_key = next(iter(self._models))
                del self._models[oldest_key]
                logger.info(f"Evicted model {oldest_key} from cache")

            self._models[model_name] = (pipe, batch_size)
            logger.info(f"Model {model_name} loaded and cached")
            return pipe, batch_size

    def _load_model(self, model_name: str) -> Tuple:
        """
        Internal method to load a Whisper model with optimizations.

        Args:
            model_name: Name of the model to load

        Returns:
            Tuple of (pipeline, batch_size)
        """
        local_model_name = self.SUPPORTED_MODELS[model_name]
        device = self._device
        batch_size = self._batch_size

        logger.info(
            f"Loading model {local_model_name} on {device} with batch size {batch_size}"
        )

        # Configure quantization (only for CUDA, not MPS)
        quantization_config = None
        use_quantization = False

        try:
            if device.startswith("cuda"):
                # Use 8-bit quantization for CUDA GPU only
                quantization_config = BitsAndBytesConfig(
                    load_in_8bit=True,
                    llm_int8_threshold=6.0,
                    llm_int8_has_fp16_weight=False,
                )
                use_quantization = True
                logger.info("8-bit quantization enabled for CUDA GPU")
        except Exception as e:
            logger.warning(
                f"Quantization setup failed: {str(e)}, continuing without quantization"
            )

        # Optimized model loading
        if device == "cpu":
            pipe = pipeline(
                "automatic-speech-recognition",
                local_model_name,
                device=device,
                model_kwargs={"use_cache": True},
            )
        else:
            model_kwargs = {
                "use_cache": True,
                "torch_dtype": torch.float16,
            }

            # Add flash attention if available and compatible (CUDA only)
            if device.startswith("cuda"):
                try:
                    import flash_attn

                    model_kwargs["attn_implementation"] = "flash_attention_2"
                    logger.info("Flash attention 2 enabled for CUDA")
                except ImportError:
                    logger.info("Flash attention not available, using standard attention")
                except Exception as e:
                    logger.warning(
                        f"Flash attention setup failed: {str(e)}, using standard attention"
                    )
            else:
                logger.info("Flash attention not available for MPS, using standard attention")

            # Create pipeline with or without quantization config
            if use_quantization and quantization_config is not None:
                pipe = pipeline(
                    "automatic-speech-recognition",
                    local_model_name,
                    device=device,
                    quantization_config=quantization_config,
                    model_kwargs=model_kwargs,
                )
            else:
                pipe = pipeline(
                    "automatic-speech-recognition",
                    local_model_name,
                    device=device,
                    model_kwargs=model_kwargs,
                )

        # Enable torch compile for additional speedup
        try:
            pipe.model = torch.compile(pipe.model, mode="reduce-overhead")
            logger.info("Torch compile enabled for model optimization")
        except Exception as e:
            logger.warning(f"Torch compile failed: {str(e)}, continuing without it")

        logger.info(f"Model {local_model_name} loaded successfully with optimizations")
        return pipe, batch_size

    def _get_optimal_device(self) -> str:
        """
        Determine the best device for Whisper inference.

        Returns:
            Device string: 'mps', 'cuda:0', or 'cpu'
        """
        if torch.backends.mps.is_available():
            logger.info("MPS (Metal Performance Shaders) is available - using GPU acceleration")
            return "mps"
        elif torch.cuda.is_available():
            logger.info("CUDA is available - using GPU acceleration")
            return "cuda:0"
        else:
            logger.info("No GPU acceleration available, falling back to CPU")
            return "cpu"

    def _get_optimal_batch_size(self, device: str) -> int:
        """
        Determine optimal batch size based on device.

        Args:
            device: Device string ('mps', 'cuda:0', or 'cpu')

        Returns:
            Optimal batch size for the device
        """
        if device == "mps":
            return 4
        elif device.startswith("cuda"):
            return 16
        else:
            return 2

    def clear_cache(self) -> None:
        """Clear all cached models."""
        with self._lock:
            self._models.clear()
            logger.info("Model cache cleared")

    def get_cache_info(self) -> Dict[str, any]:
        """
        Get information about cached models.

        Returns:
            Dictionary with cache statistics
        """
        with self._lock:
            return {
                "cached_models": list(self._models.keys()),
                "cache_size": len(self._models),
                "max_cache_size": self._max_cache_size,
                "device": self._device,
                "batch_size": self._batch_size,
            }

# Whisper API Server

A high-performance, production-ready Python FastAPI server that provides local Whisper transcription with an OpenAI-compatible API interface.

## Features

- ✅ **Local Processing**: Runs Whisper models locally on your hardware
- ✅ **OpenAI Compatible**: Uses OpenAI's API format for seamless integration
- ✅ **High Performance**: Optimized for speed with quantization, flash attention, and hardware acceleration
- ✅ **Multi-GPU Support**: CUDA, MPS (Apple Silicon), and CPU compatibility
- ✅ **Audio Preprocessing**: Automatic resampling, normalization, and silence trimming
- ✅ **Secure**: Input validation, file size limits, format detection
- ✅ **Configurable**: Environment-based configuration
- ✅ **Production-ready**: Error handling, logging, health checks, 90%+ test coverage
- ✅ **Multi-format Support**: MP3, MP4, M4A, WAV, FLAC, OGG, WebM
- ✅ **Modular Architecture**: Clean separation of concerns, dependency injection
- ✅ **Thread-safe**: Concurrent request handling with proper locking

## Performance Optimizations

### **🚀 Speed Improvements**
- **4-6x faster** than basic Whisper implementations
- **8-bit quantization** for GPU acceleration (CUDA)
- **Flash Attention 2** for faster attention computation (CUDA)
- **Torch compile** for JIT optimization
- **Optimized batch sizes** based on hardware
- **Audio preprocessing** for optimal model performance
- **Smaller default model** (whisper-tiny) for speed

### **🔧 Hardware Optimizations**
- **CUDA**: Full optimizations (quantization + flash attention + high batch sizes)
- **MPS (Apple Silicon)**: GPU acceleration with optimized parameters
- **CPU**: Optimized batch processing and model caching

## Architecture

### **Directory Structure**
```
whisper_server/
├── api/
│   ├── __init__.py
│   ├── models.py              # Pydantic request/response models
│   └── routes.py              # API endpoint definitions
├── services/
│   ├── __init__.py
│   ├── audio_processor.py     # Audio preprocessing service
│   └── model_manager.py       # Model loading and caching service
├── core/
│   ├── __init__.py
│   ├── config.py              # Configuration management
│   └── validators.py          # Input validation functions
├── tests/
│   ├── __init__.py
│   ├── conftest.py            # Shared test fixtures
│   ├── test_validators.py    # Validator unit tests
│   ├── test_config.py         # Config unit tests
│   └── integration/
│       └── test_api.py        # API integration tests
├── whisper_api_server.py      # Main application entry point
├── requirements.txt           # Production dependencies
├── requirements-test.txt      # Testing dependencies
└── pytest.ini                 # Test configuration
```

### **Key Components**

**Services:**
- `ModelManager`: Thread-safe model loading/caching with LRU eviction
- `AudioProcessor`: Audio preprocessing (resampling, normalization, trimming)

**API Layer:**
- `routes.py`: HTTP endpoints with dependency injection
- `models.py`: Request/response validation with Pydantic

**Core:**
- `config.py`: Environment-based configuration
- `validators.py`: Input validation (base64, formats, model names)

## Setup

### **1. Install Dependencies**

**For Intel/AMD CPUs or NVIDIA GPUs:**
```bash
cd whisper_server
pip install -r requirements.txt
```

**For Apple Silicon (M1/M2/M3 Macs):**
```bash
cd whisper_server
pip install -r requirements_macos_arm.txt
```

**For Development/Testing:**
```bash
pip install -r requirements-test.txt
```

**Note**: Some optimizations require specific hardware/software:
- **Flash Attention**: Requires CUDA and may need compilation (NVIDIA GPUs only)
- **8-bit Quantization**: Works best with CUDA GPUs
- **MPS**: Automatic on Apple Silicon Macs (use requirements_macos_arm.txt)

### **2. Configure Environment (Optional)**
```bash
export WHISPER_SERVER_PORT="8089"
export MAX_AUDIO_FILE_SIZE_MB="25"
export LOG_LEVEL="INFO"
export ALLOWED_ORIGINS="http://localhost:3000"
```

## Usage

### **Start the Server**
```bash
python whisper_api_server.py
```

The server will:
- Start on `http://127.0.0.1:8089` by default
- Automatically detect and optimize for your hardware
- Download models on first use (models are cached afterward)
- Log performance optimizations being used

### **Building and Running as Executable**

Build a standalone executable using PyInstaller:

1. **Install PyInstaller:**
   ```bash
   pip install pyinstaller
   ```

2. **Build the executable:**
   ```bash
   pyinstaller whisper_api_server.spec
   ```

3. **Run the executable:**
   ```bash
   ./dist/whisper_api_server
   ```

### **Command Line Tool**

For direct file transcription, use the CLI tool:

```bash
python whisper_server.py path/to/audio.m4a
```

## API Endpoints

### **POST `/v1/audio/transcriptions`**
Transcribe audio using local Whisper models.

**Request:**
```json
{
  "audio": "base64_encoded_audio_data",
  "model": "whisper-1",
  "language": "auto"
}
```

**Response:**
```json
{
  "text": "Transcribed text here...",
  "processing_time": 1.2,
  "model": "whisper-1",
  "format": "m4a"
}
```

### **POST `/v1/chat/completions`**
OpenAI-compatible endpoint that proxies to `/v1/audio/transcriptions`.

### **GET `/health`**
Health check endpoint.

### **POST `/debug/audio-info`**
Debug endpoint to get information about audio data without transcribing.

## Supported Models

The server supports the following Whisper models (optimized for performance):

| Model | Size | Speed | Quality | Default |
|-------|------|-------|---------|---------|
| `whisper-1` | ~39MB | Fastest | Good | ✅ |
| `whisper-tiny` | ~39MB | Fastest | Good | |
| `whisper-small` | ~244MB | Fast | Better | |
| `whisper-medium` | ~769MB | Medium | Better | |
| `whisper-large` | ~1550MB | Slow | Best | |

**Note**: `whisper-1` maps to `whisper-tiny` for optimal speed.

## Hardware Requirements

### **Minimum Requirements**
- **CPU**: Any modern CPU
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 1-3GB for models (downloaded automatically)

### **Optimized Performance**
- **CUDA GPU**: NVIDIA GPU with CUDA support (best performance)
- **Apple Silicon**: M1/M2/M3 Macs with MPS support (very good performance)
- **Modern CPU**: Intel/AMD with AVX support (good performance)

## Performance Benchmarks

Typical transcription times for 1-minute audio:

| Hardware | Model | Time | Speedup |
|----------|-------|------|---------|
| M1 Mac (MPS) | whisper-tiny | ~2-4s | 4-6x |
| RTX 3080 (CUDA) | whisper-tiny | ~1-2s | 6-8x |
| Intel i7 (CPU) | whisper-tiny | ~8-15s | 2-3x |

*Times include preprocessing and model loading on first run*

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WHISPER_SERVER_HOST` | `127.0.0.1` | Server host address |
| `WHISPER_SERVER_PORT` | `8089` | Server port |
| `MAX_AUDIO_FILE_SIZE_MB` | `25` | Maximum audio file size in MB |
| `ALLOWED_ORIGINS` | `http://localhost:3000` | CORS allowed origins (comma-separated) |
| `ALLOWED_HOSTS` | `*` | Trusted hosts (comma-separated) |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |

## Integration with Bockaire

Configure the Whisper provider in the Bockaire app:

1. Open **Settings** > **AI Settings**
2. Select **Whisper** as the transcription provider
3. Set **Base URL**: `http://localhost:8089`
4. Leave **API Key** empty (not required for local server)
5. Choose a **Model**: `whisper-1` for speed or `whisper-small` for quality

The app will automatically use the OpenAI-compatible API format.

## Troubleshooting

### **Common Issues**

**Model Download Slow/Fails**
- Check internet connection for first-time model download
- Models are cached locally after first download

**Flash Attention Errors**
- Flash attention only works on CUDA GPUs
- Server automatically falls back to standard attention
- This is normal and expected on MPS/CPU

**Memory Issues**
- Use smaller models (`whisper-tiny` or `whisper-small`)
- Reduce batch size by setting lower values in environment
- Close other applications to free up memory

**Port Already in Use**
- Change port: `export WHISPER_SERVER_PORT="8090"`
- Check if another Whisper server is running

### **Performance Tips**

1. **For fastest transcription**: Use `whisper-tiny` model
2. **For best quality**: Use `whisper-large` model
3. **For CUDA GPUs**: Ensure CUDA drivers are up to date
4. **For Apple Silicon**: Ensure macOS is updated for best MPS support
5. **First run**: Allow extra time for model download and compilation

## Testing

### **Run Tests**

```bash
# Run all tests with coverage
pytest

# Run specific test file
pytest tests/test_validators.py -v

# Run unit tests only
pytest tests/test_*.py -v

# Run integration tests only
pytest tests/integration/ -v

# Generate coverage report
pytest --cov=. --cov-report=html
open htmlcov/index.html
```

### **Test Coverage**

Current test coverage: **90%+**

- `validators.py`: 95%+ coverage
- `config.py`: 90%+ coverage
- API endpoints: 85%+ coverage
- Services: 80%+ coverage

## Development

### **Code Quality**

The codebase follows these principles:
- **SOLID principles**: Single responsibility, dependency injection
- **Type hints**: Comprehensive type annotations
- **Clean architecture**: Separation of concerns (API, services, core)
- **Thread safety**: Explicit locking for concurrent operations
- **Error handling**: Specific exceptions, proper logging

### **Making Changes**

1. Create a new branch
2. Make changes to code
3. Add/update tests
4. Run tests: `pytest`
5. Check coverage: `pytest --cov`
6. Ensure all tests pass before committing

## Dependencies

The server requires the following key packages:

**Production:**
```
torch>=2.0.0              # PyTorch for model inference
transformers>=4.30.0       # Hugging Face transformers
accelerate>=0.20.0         # Hardware acceleration
bitsandbytes>=0.43.0       # 8-bit quantization
flash-attn>=2.0.0          # Flash attention (CUDA only)
librosa>=0.10.0            # Audio processing
soundfile>=0.12.0          # Audio file I/O
audioread>=3.0.0           # Audio format support
fastapi>=0.68.0            # Web framework
uvicorn>=0.15.0            # ASGI server
```

**Testing:**
```
pytest>=7.0.0              # Test framework
pytest-cov>=4.0.0          # Coverage reporting
pytest-asyncio>=0.21.0     # Async test support
httpx>=0.24.0              # HTTP client for testing
```

**Note**: Some packages (flash-attn, bitsandbytes) may require compilation and are optional for basic functionality.

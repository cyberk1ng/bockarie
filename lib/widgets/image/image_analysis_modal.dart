import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/services/ollama_packing_list_service.dart';
import 'package:bockaire/services/ollama_model_manager.dart';
import 'package:bockaire/providers/image_analysis_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ImageAnalysisState { idle, analyzing, success, error }

class ImageAnalysisModal extends ConsumerStatefulWidget {
  const ImageAnalysisModal({super.key});

  @override
  ConsumerState<ImageAnalysisModal> createState() => _ImageAnalysisModalState();
}

class _ImageAnalysisModalState extends ConsumerState<ImageAnalysisModal> {
  ImageAnalysisState _state = ImageAnalysisState.idle;
  String? _errorMessage;
  File? _selectedImage;
  List<CartonData> _detectedCartons = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Automatically show image picker when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  Future<void> _pickImage() async {
    try {
      // Show options to pick from camera or gallery
      final source = await _showImageSourceDialog();
      if (source == null) {
        // User cancelled
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled image picker
        if (mounted) Navigator.of(context).pop();
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
      });

      // Automatically start analysis
      await _analyzeImage();
    } catch (e) {
      setState(() {
        _state = ImageAnalysisState.error;
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _state = ImageAnalysisState.analyzing;
      _errorMessage = null;
    });

    try {
      // Get selected provider
      final selectedProvider = ref.read(imageAnalysisProviderProvider);

      AiImageAnalyzer analyzer;

      if (selectedProvider == ImageAnalysisProviderType.gemini) {
        // Get Gemini API key
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        if (apiKey.isEmpty) {
          throw Exception(
            'Gemini API key not found. Please check your .env file',
          );
        }

        // Get selected model
        final model = ref.read(geminiVisionModelProvider);

        // Create Gemini analyzer with selected model
        analyzer = GeminiImageAnalyzer(apiKey: apiKey, model: model);
      } else {
        // Ollama provider
        final baseUrl = ref.read(ollamaBaseUrlProvider);
        final model = ref.read(ollamaVisionModelProvider);

        // Check if Ollama server is available
        final modelManager = OllamaModelManager(baseUrl: baseUrl);
        final isServerAvailable = await modelManager.isServerAvailable();

        if (!isServerAvailable) {
          throw Exception(
            'Cannot connect to Ollama server at $baseUrl.\n\n'
            'Please ensure:\n'
            '• Ollama is installed and running\n'
            '• The server URL is correct in settings',
          );
        }

        // Check if model is installed
        final isModelInstalled = await modelManager.isModelInstalled(model);

        if (!isModelInstalled) {
          throw ModelNotInstalledException(model);
        }

        // Create Ollama analyzer
        analyzer = OllamaPackingListService(baseUrl: baseUrl, model: model);
      }

      // Analyze image
      final cartons = await analyzer.extractCartonsFromImage(_selectedImage!);

      if (cartons.isEmpty) {
        throw Exception(
          'No cartons detected in the image.\n\n'
          'Please ensure the image contains a clear packing list with:\n'
          '• Dimensions (length × width × height)\n'
          '• Weight\n'
          '• Quantity\n'
          '• Item type',
        );
      }

      setState(() {
        _detectedCartons = cartons;
        _state = ImageAnalysisState.success;
      });
    } on ModelNotInstalledException catch (e) {
      setState(() {
        _state = ImageAnalysisState.error;
        _errorMessage =
            'Model "${e.modelName}" is not installed.\n\n'
            'Please install it by running:\n'
            'ollama pull ${e.modelName}\n\n'
            'Or select a different model in Settings → AI Providers';
      });
    } catch (e) {
      setState(() {
        _state = ImageAnalysisState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _confirmAndFinish() {
    Navigator.of(context).pop(_detectedCartons);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _retryWithNewImage() {
    setState(() {
      _state = ImageAnalysisState.idle;
      _selectedImage = null;
      _detectedCartons = [];
      _errorMessage = null;
    });
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Row(
                children: [
                  Icon(Icons.image, color: _getIconColor(), size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Scan Packing List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: _cancel),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Flexible(child: SingleChildScrollView(child: _buildContent())),

              const SizedBox(height: 24),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case ImageAnalysisState.idle:
        return const Column(
          children: [
            Icon(Icons.image_search, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Selecting image...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        );

      case ImageAnalysisState.analyzing:
        return Column(
          children: [
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Analyzing packing list...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );

      case ImageAnalysisState.success:
        return _buildSuccessContent();

      case ImageAnalysisState.error:
        return Column(
          children: [
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryWithNewImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Another Image'),
            ),
          ],
        );
    }
  }

  Widget _buildSuccessContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image preview
        if (_selectedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ],

        // Success header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Found ${_detectedCartons.length} carton${_detectedCartons.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detected cartons list
        ...List.generate(_detectedCartons.length, (index) {
          final carton = _detectedCartons[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carton ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dimensions',
                  '${carton.lengthCm} × ${carton.widthCm} × ${carton.heightCm} cm',
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Weight', '${carton.weightKg} kg'),
                const SizedBox(height: 8),
                _buildDetailRow('Quantity', '${carton.qty}'),
                const SizedBox(height: 8),
                _buildDetailRow('Item Type', carton.itemType ?? 'Unknown'),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (_state == ImageAnalysisState.success) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _retryWithNewImage,
            child: const Text('Try Another'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _confirmAndFinish,
            icon: const Icon(Icons.check),
            label: Text(
              'Add ${_detectedCartons.length} Carton${_detectedCartons.length != 1 ? 's' : ''}',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_state == ImageAnalysisState.error) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(onPressed: _cancel, child: const Text('Close')),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(onPressed: _cancel, child: const Text('Cancel')),
    );
  }

  Color _getIconColor() {
    switch (_state) {
      case ImageAnalysisState.analyzing:
        return Colors.orange;
      case ImageAnalysisState.success:
        return Colors.green;
      case ImageAnalysisState.error:
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}

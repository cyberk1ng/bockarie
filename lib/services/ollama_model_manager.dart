import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ModelInstallProgress {
  final String status;
  final int total;
  final int completed;

  ModelInstallProgress({
    required this.status,
    required this.total,
    required this.completed,
  });

  double get progress => total > 0 ? completed / total : 0.0;
  String get percentage => '${(progress * 100).toStringAsFixed(1)}%';

  @override
  String toString() => '$status - $percentage';
}

class ModelInfo {
  final String name;
  final int size;
  final String modifiedAt;

  ModelInfo({required this.name, required this.size, required this.modifiedAt});

  String get sizeInGB =>
      '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      name: json['name'] as String,
      size: json['size'] as int? ?? 0,
      modifiedAt: json['modified_at'] as String? ?? '',
    );
  }
}

class OllamaModelManager {
  final String baseUrl;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  OllamaModelManager({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Check if Ollama server is running and reachable
  Future<bool> isServerAvailable() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      _logger.w('Ollama server not available: $e');
      return false;
    }
  }

  /// Check if a specific model is installed
  Future<bool> isModelInstalled(String modelName) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = data['models'] as List? ?? [];

      return models.any((m) => m['name'] == modelName);
    } catch (e) {
      _logger.e('Error checking if model is installed: $e');
      return false;
    }
  }

  /// Get list of installed models
  Future<List<ModelInfo>> getInstalledModels() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to get models: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = data['models'] as List? ?? [];

      return models
          .map((m) => ModelInfo.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error getting installed models: $e');
      rethrow;
    }
  }

  /// Install a model with progress updates
  Stream<ModelInstallProgress> installModel(String modelName) async* {
    try {
      _logger.i('Starting installation of model: $modelName');

      final request = http.Request('POST', Uri.parse('$baseUrl/api/pull'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'name': modelName});

      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to start model installation: ${response.statusCode}',
        );
      }

      await for (final chunk
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (chunk.isEmpty) continue;

        try {
          final json = jsonDecode(chunk) as Map<String, dynamic>;

          yield ModelInstallProgress(
            status: json['status'] as String? ?? 'Processing...',
            total: json['total'] as int? ?? 0,
            completed: json['completed'] as int? ?? 0,
          );

          // Check if installation is complete
          if (json['status'] == 'success') {
            _logger.i('Model installation complete: $modelName');
            break;
          }
        } catch (e) {
          _logger.w('Error parsing progress chunk: $e');
        }
      }
    } on SocketException {
      _logger.e('Network error during model installation');
      throw Exception('Cannot connect to Ollama server at $baseUrl');
    } catch (e, stackTrace) {
      _logger.e('Error installing model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a model
  Future<void> deleteModel(String modelName) async {
    try {
      _logger.i('Deleting model: $modelName');

      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/api/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': modelName}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete model: ${response.statusCode}');
      }

      _logger.i('Model deleted successfully: $modelName');
    } catch (e, stackTrace) {
      _logger.e('Error deleting model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Warm up a model by sending a dummy request
  Future<void> warmUpModel(String modelName) async {
    try {
      _logger.i('Warming up model: $modelName');

      final requestBody = {
        'model': modelName,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'stream': false,
      };

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        _logger.i('Model warmed up successfully: $modelName');
      }
    } catch (e) {
      _logger.w('Error warming up model: $e');
      // Non-critical error, don't throw
    }
  }

  /// Get recommended vision models
  static List<String> get recommendedVisionModels => [
    'llava:13b',
    'minicpm-v:8b',
    'bakllava:7b',
  ];
}

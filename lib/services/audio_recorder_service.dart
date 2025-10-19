import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:logger/logger.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final Logger _logger = Logger();
  String? _currentRecordingPath;

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      // Check permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _logger.w('Microphone permission denied');
        return false;
      }

      // Create file path - use app documents directory instead of temp
      // (temp dir on macOS may have restrictions)
      final appDocDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${appDocDir.path}/carton_voice_$timestamp.m4a';

      // Start recording with simple config
      // Let the package choose defaults - fixes macOS recording issues
      await _recorder.start(
        const RecordConfig(sampleRate: 48000, autoGain: true),
        path: _currentRecordingPath!,
      );

      _logger.i('Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      _logger.e('Failed to start recording: $e');
      return false;
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _logger.i('🛑 Recorder.stop() returned: $path');

      // Check file size and details
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          final size = await file.length();
          final sizeKB = size / 1024;
          final sizeMB = size / (1024 * 1024);
          _logger.i(
            '📊 Recording stopped: $sizeKB KB (${sizeMB.toStringAsFixed(2)} MB)',
          );
          _logger.i('📁 File path: $_currentRecordingPath');
          _logger.i('✅ File exists: ${await file.exists()}');
        } else {
          _logger.e('❌ File does NOT exist at path: $_currentRecordingPath');
        }
      } else {
        _logger.w('⚠️ No recording path set');
      }

      return _currentRecordingPath;
    } catch (e) {
      _logger.e('Failed to stop recording: $e');
      return null;
    }
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Get amplitude stream for VU meter
  Stream<Amplitude> get amplitudeStream =>
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 50));

  /// Clean up resources
  void dispose() {
    _recorder.dispose();
  }
}

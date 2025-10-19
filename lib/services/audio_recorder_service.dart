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

      // Create file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/carton_voice_$timestamp.m4a';

      // Start recording (same config as Lotti)
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 48000, // High quality
          autoGain: true, // Normalize volume
        ),
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
      await _recorder.stop();

      // Check file size
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        final size = await file.length();
        final sizeKB = size / 1024;
        _logger.i('Recording stopped: $sizeKB KB');
      } else {
        _logger.i('Recording stopped');
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

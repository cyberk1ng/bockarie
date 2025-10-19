import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bockaire/services/audio_recorder_service.dart';
import 'package:bockaire/services/whisper_transcription_service.dart';
import 'package:bockaire/services/carton_voice_parser_service.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/get_it.dart';

enum VoiceModalState { idle, recording, processing, success, error }

class VoiceInputModal extends StatefulWidget {
  const VoiceInputModal({super.key});

  @override
  State<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends State<VoiceInputModal> {
  VoiceModalState _state = VoiceModalState.idle;
  String? _errorMessage;
  CartonData? _detectedCarton;
  String? _transcribedText;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  late final AudioRecorderService _recorder;
  late final WhisperTranscriptionService _whisper;
  late final CartonVoiceParserService _parser;

  @override
  void initState() {
    super.initState();
    _recorder = getIt<AudioRecorderService>();
    _whisper = getIt<WhisperTranscriptionService>();
    _parser = getIt<CartonVoiceParserService>();
    // Don't auto-start - wait for user to click
  }

  Future<void> _startRecording() async {
    final started = await _recorder.startRecording();
    if (started) {
      setState(() {
        _state = VoiceModalState.recording;
        _recordingSeconds = 0;
      });

      // Start timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordingSeconds++);
        }
      });
    } else {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage = 'Microphone permission denied';
      });
    }
  }

  Future<void> _stopAndProcess() async {
    // Stop timer
    _recordingTimer?.cancel();

    // Check minimum duration
    if (_recordingSeconds < 3) {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage = 'Recording too short! Please record for at least 3 seconds.';
      });
      return;
    }

    setState(() => _state = VoiceModalState.processing);

    try {
      // Stop recording
      final audioPath = await _recorder.stopRecording();
      if (audioPath == null) throw Exception('No audio recorded');

      // Transcribe with Whisper
      final text = await _whisper.transcribe(audioPath);

      print('🔊 Transcribed text: "$text" (${text.length} chars)');

      if (text.isEmpty) throw Exception('No speech detected');

      setState(() => _transcribedText = text);

      // Parse with Gemini
      final cartonData = await _parser.parseCartonFromText(
        transcribedText: text,
      );

      if (cartonData == null || !cartonData.isComplete) {
        throw Exception('Could not understand carton details. Please try again.');
      }

      // Success!
      setState(() {
        _state = VoiceModalState.success;
        _detectedCarton = cartonData;
      });
    } catch (e) {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _addCarton() {
    if (_detectedCarton != null) {
      Navigator.of(context).pop(_detectedCarton);
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Make sure recording is stopped
    _recordingTimer?.cancel();
    _recorder.stopRecording();
    super.dispose();
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
                  Icon(
                    Icons.mic,
                    color: _getIconColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Carton by Voice',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancel,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              _buildContent(),

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
      case VoiceModalState.idle:
        return Column(
          children: [
            const Icon(Icons.mic_none, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Ready to record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Start Recording" and say:\n"50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        );

      case VoiceModalState.recording:
        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fiber_manual_record,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recording... $_recordingSeconds seconds',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _recordingSeconds < 3
                  ? 'Keep speaking... (minimum 3 seconds)'
                  : 'Click "Stop" when finished',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _recordingSeconds < 3 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Example: "50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _stopAndProcess,
              icon: const Icon(Icons.stop),
              label: const Text('Stop & Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _recordingSeconds >= 3 ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );

      case VoiceModalState.processing:
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Processing...'),
            if (_transcribedText != null) ...[
              const SizedBox(height: 8),
              Text(
                'Heard: "$_transcribedText"',
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );

      case VoiceModalState.success:
        return _buildSuccessContent();

      case VoiceModalState.error:
        return Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _state = VoiceModalState.idle;
                  _errorMessage = null;
                });
                _startRecording();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
    }
  }

  Widget _buildSuccessContent() {
    final carton = _detectedCarton!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Text(
                'Detected:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Dimensions', '${carton.lengthCm} × ${carton.widthCm} × ${carton.heightCm} cm'),
          const SizedBox(height: 8),
          _buildDetailRow('Weight', '${carton.weightKg} kg'),
          const SizedBox(height: 8),
          _buildDetailRow('Quantity', '${carton.qty}'),
          const SizedBox(height: 8),
          _buildDetailRow('Item Type', carton.itemType ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (_state == VoiceModalState.success) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _cancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _addCarton,
            icon: const Icon(Icons.add),
            label: const Text('Add Carton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_state == VoiceModalState.error) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _cancel,
          child: const Text('Close'),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _cancel,
        child: const Text('Cancel'),
      ),
    );
  }

  Color _getIconColor() {
    switch (_state) {
      case VoiceModalState.recording:
        return Colors.red;
      case VoiceModalState.processing:
        return Colors.orange;
      case VoiceModalState.success:
        return Colors.green;
      case VoiceModalState.error:
        return Colors.red.shade300;
      default:
        return Colors.blue;
    }
  }
}

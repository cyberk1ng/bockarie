import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/services/audio_recorder_service.dart';
import 'package:bockaire/services/whisper_transcription_service.dart';
import 'package:bockaire/services/gemini_audio_transcription_service.dart';
import 'package:bockaire/services/carton_voice_parser_service.dart';
import 'package:bockaire/services/location_voice_parser_service.dart';
import 'package:bockaire/services/city_matcher_service.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/providers/transcription_provider.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/widgets/voice/circular_pulse_visualizer.dart';

enum VoiceModalState { idle, recording, processing, success, error }

class VoiceInputModal extends ConsumerStatefulWidget {
  final bool hasExistingLocation;

  const VoiceInputModal({this.hasExistingLocation = false, super.key});

  @override
  ConsumerState<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends ConsumerState<VoiceInputModal> {
  final Logger _logger = Logger();
  VoiceModalState _state = VoiceModalState.idle;
  String? _errorMessage;

  // Location data
  String? _originCity;
  String? _originPostal;
  String? _originCountry;
  String? _originState;
  String? _destCity;
  String? _destPostal;
  String? _destCountry;
  String? _destState;

  // Carton data
  CartonData? _detectedCarton;

  String? _transcribedText;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  late final AudioRecorderService _recorder;
  late final WhisperTranscriptionService _whisper;
  late final GeminiAudioTranscriptionService _gemini;
  late final CartonVoiceParserService _cartonParser;
  late final LocationVoiceParserService _locationParser;
  late final CityMatcherService _cityMatcher;

  @override
  void initState() {
    super.initState();
    _recorder = getIt<AudioRecorderService>();
    _whisper = getIt<WhisperTranscriptionService>();
    _gemini = getIt<GeminiAudioTranscriptionService>();
    _cartonParser = getIt<CartonVoiceParserService>();
    _locationParser = getIt<LocationVoiceParserService>();
    _cityMatcher = getIt<CityMatcherService>();
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

    _logger.d('⏱️ Recording duration: $_recordingSeconds seconds');

    // Check minimum duration
    if (_recordingSeconds < 3) {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage =
            'Recording too short! Please record for at least 3 seconds.';
      });
      return;
    }

    setState(() => _state = VoiceModalState.processing);

    try {
      // Stop recording
      _logger.d('🎙️ Stopping recording...');
      final audioPath = await _recorder.stopRecording();
      _logger.d('📁 Audio path received: $audioPath');

      if (audioPath == null) throw Exception('No audio recorded');

      // Get selected transcription provider from settings
      final selectedProvider = ref.read(transcriptionProviderProvider);
      _logger.d('🔧 Selected provider: $selectedProvider');

      // Transcribe with the selected provider
      _logger.d('🚀 Starting transcription with $selectedProvider...');
      final text = selectedProvider == TranscriptionProviderType.gemini
          ? await _gemini.transcribe(audioPath)
          : await _whisper.transcribe(audioPath);

      _logger.d(
        '🔊 Transcribed text ($selectedProvider): "$text" (${text.length} chars)',
      );

      if (text.isEmpty) throw Exception('No speech detected');

      setState(() => _transcribedText = text);

      // Parse both location and carton from the same recording
      await _processRecording(text);
    } catch (e) {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _processRecording(String text) async {
    _logger.d('🎤 Processing recording...');
    _logger.d('🔒 Has existing location: ${widget.hasExistingLocation}');

    bool hasLocation = false;
    bool hasCarton = false;

    // Only try to parse location if fields are NOT already filled
    if (!widget.hasExistingLocation) {
      _logger.d('📍 Attempting to parse location (fields are empty)...');
      try {
        final locationData = await _locationParser.parseLocationFromText(
          transcribedText: text,
        );

        if (locationData != null && locationData.isComplete) {
          _logger.d(
            '📍 Parsed locations: ${locationData.originCity} → ${locationData.destinationCity}',
          );

          // Match origin city
          final originMatch = await _cityMatcher.findCity(
            locationData.originCity!,
          );
          if (originMatch != null) {
            _logger.d(
              '✅ Origin matched: ${originMatch.city}, ${originMatch.postal}, ${originMatch.country}',
            );

            _originCity = originMatch.city;
            _originPostal = originMatch.postal;
            _originCountry = originMatch.country;
            _originState = originMatch.state;
            hasLocation = true;
          }

          // Match destination city
          final destMatch = await _cityMatcher.findCity(
            locationData.destinationCity!,
          );
          if (destMatch != null) {
            _logger.d(
              '✅ Destination matched: ${destMatch.city}, ${destMatch.postal}, ${destMatch.country}',
            );

            _destCity = destMatch.city;
            _destPostal = destMatch.postal;
            _destCountry = destMatch.country;
            _destState = destMatch.state;
          } else {
            hasLocation = false; // Need both cities
          }
        }
      } catch (e) {
        _logger.w('⚠️ Could not parse location: $e');
        // Continue - location is optional
      }
    } else {
      _logger.d(
        '⏭️ Skipping location parsing - fields already filled (security feature)',
      );
    }

    // Try to parse carton
    try {
      final cartonData = await _cartonParser.parseCartonFromText(
        transcribedText: text,
      );

      if (cartonData != null && cartonData.isComplete) {
        _logger.d('📦 Parsed carton: $cartonData');
        _detectedCarton = cartonData;
        hasCarton = true;
      }
    } catch (e) {
      _logger.w('⚠️ Could not parse carton: $e');
      // Continue - carton is optional
    }

    // Check if we got at least something
    if (!hasLocation && !hasCarton) {
      if (widget.hasExistingLocation) {
        // Location already set, only carton needed
        throw Exception(
          'Could not understand carton details.\n\n'
          'Please say:\n'
          '"[dimensions], [weight], [quantity], [item type]"\n\n'
          'Example: "50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
        );
      } else {
        // Need both location and carton
        throw Exception(
          'Could not understand your recording.\n\n'
          'Please say:\n'
          '"From [city] to [city], [dimensions], [weight], [quantity], [item type]"\n\n'
          'Example: "From Shanghai to New York, 50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
        );
      }
    }

    // Success!
    setState(() {
      _state = VoiceModalState.success;
    });
  }

  void _addAndFinish() {
    // Return complete result with location and carton data
    final result = VoiceInputResult(
      originCity: _originCity,
      originPostal: _originPostal,
      originCountry: _originCountry,
      originState: _originState,
      destCity: _destCity,
      destPostal: _destPostal,
      destCountry: _destCountry,
      destState: _destState,
      cartonData: _detectedCarton,
    );
    Navigator.of(context).pop(result);
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
                  Icon(Icons.mic, color: _getIconColor(), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Shipment by Voice',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: _cancel),
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
            const CircularPulseVisualizer(
              isRecording: false,
              size: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.hasExistingLocation
                  ? 'Cities already set. Just say carton details:\n"50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"'
                  : 'Click "Start Recording" and say everything in one go:\n"From Shanghai to New York, 50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        );

      case VoiceModalState.recording:
        return Column(
          children: [
            const CircularPulseVisualizer(
              isRecording: true,
              size: 150,
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
            Text(
              widget.hasExistingLocation
                  ? 'Say carton details:\n"50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"'
                  : 'Say cities and carton details:\n"From Shanghai to New York, 50 by 30 by 20 cm, 5 kg, 10 pieces, laptops"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _stopAndProcess,
              icon: const Icon(Icons.stop),
              label: const Text('Stop & Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _recordingSeconds >= 3
                    ? Colors.green
                    : Colors.red,
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
    final hasLocation = _originCity != null && _destCity != null;
    final hasCarton = _detectedCarton != null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Transcript section
        if (_transcribedText != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You said:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_transcribedText"',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Location section
        if (hasLocation) ...[
          Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Route Detected:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'From',
                  '$_originCity, $_originPostal, $_originCountry',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'To',
                  '$_destCity, $_destPostal, $_destCountry',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Carton section
        if (hasCarton) ...[
          Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Carton Detected:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dimensions',
                  '${_detectedCarton!.lengthCm} × ${_detectedCarton!.widthCm} × ${_detectedCarton!.heightCm} cm',
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Weight', '${_detectedCarton!.weightKg} kg'),
                const SizedBox(height: 8),
                _buildDetailRow('Quantity', '${_detectedCarton!.qty}'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Item Type',
                  _detectedCarton!.itemType ?? 'Unknown',
                ),
              ],
            ),
          ),
        ],
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
    if (_state == VoiceModalState.success) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: _cancel, child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _addAndFinish,
            icon: const Icon(Icons.check),
            label: const Text('Add Shipment'),
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

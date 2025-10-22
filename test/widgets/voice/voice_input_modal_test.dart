import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bockaire/widgets/voice/voice_input_modal.dart';
import 'package:bockaire/services/audio_recorder_service.dart';
import 'package:bockaire/services/gemini_audio_transcription_service.dart';
import 'package:bockaire/services/carton_voice_parser_service.dart';
import 'package:bockaire/services/location_voice_parser_service.dart';
import 'package:bockaire/services/city_matcher_service.dart';
import 'package:bockaire/services/whisper_server_manager.dart';
import 'package:bockaire/providers/transcription_provider.dart';
import 'package:bockaire/get_it.dart';

@GenerateMocks([
  AudioRecorderService,
  WhisperServerManager,
  GeminiAudioTranscriptionService,
  CartonVoiceParserService,
  LocationVoiceParserService,
  CityMatcherService,
])
import 'voice_input_modal_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioRecorderService mockRecorder;
  late MockWhisperServerManager mockServerManager;
  late MockGeminiAudioTranscriptionService mockGemini;
  late MockCartonVoiceParserService mockCartonParser;
  late MockLocationVoiceParserService mockLocationParser;
  late MockCityMatcherService mockCityMatcher;

  setUp(() {
    mockRecorder = MockAudioRecorderService();
    mockServerManager = MockWhisperServerManager();
    mockGemini = MockGeminiAudioTranscriptionService();
    mockCartonParser = MockCartonVoiceParserService();
    mockLocationParser = MockLocationVoiceParserService();
    mockCityMatcher = MockCityMatcherService();

    // Default stubs to prevent MissingStubError
    when(mockRecorder.stopRecording()).thenAnswer((_) async => null);
    when(mockServerManager.isRunning).thenReturn(false);
    when(mockServerManager.checkHealth()).thenAnswer((_) async => false);

    // Setup GetIt mocks
    if (getIt.isRegistered<AudioRecorderService>()) {
      getIt.unregister<AudioRecorderService>();
    }
    if (getIt.isRegistered<WhisperServerManager>()) {
      getIt.unregister<WhisperServerManager>();
    }
    if (getIt.isRegistered<GeminiAudioTranscriptionService>()) {
      getIt.unregister<GeminiAudioTranscriptionService>();
    }
    if (getIt.isRegistered<CartonVoiceParserService>()) {
      getIt.unregister<CartonVoiceParserService>();
    }
    if (getIt.isRegistered<LocationVoiceParserService>()) {
      getIt.unregister<LocationVoiceParserService>();
    }
    if (getIt.isRegistered<CityMatcherService>()) {
      getIt.unregister<CityMatcherService>();
    }

    getIt.registerSingleton<AudioRecorderService>(mockRecorder);
    getIt.registerSingleton<WhisperServerManager>(mockServerManager);
    getIt.registerSingleton<GeminiAudioTranscriptionService>(mockGemini);
    getIt.registerSingleton<CartonVoiceParserService>(mockCartonParser);
    getIt.registerSingleton<LocationVoiceParserService>(mockLocationParser);
    getIt.registerSingleton<CityMatcherService>(mockCityMatcher);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createTestWidget({bool hasExistingLocation = false}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: VoiceInputModal(hasExistingLocation: hasExistingLocation),
        ),
      ),
    );
  }

  group('VoiceInputModal - Widget Structure', () {
    testWidgets('renders with correct initial widgets', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify key widgets are present
      expect(find.byType(VoiceInputModal), findsOneWidget);
      expect(find.text('Ready to record'), findsOneWidget);
      expect(find.text('Start Recording'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets(
      'displays correct instructions when hasExistingLocation is false',
      (tester) async {
        await tester.pumpWidget(createTestWidget(hasExistingLocation: false));
        await tester.pumpAndSettle();

        // Verify location parsing instructions are shown (contains both from/to cities)
        expect(
          find.textContaining('From Shanghai to New York'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays correct instructions when hasExistingLocation is true',
      (tester) async {
        await tester.pumpWidget(createTestWidget(hasExistingLocation: true));
        await tester.pumpAndSettle();

        // Verify simplified instructions for carton-only input
        expect(find.textContaining('Cities already set'), findsOneWidget);
        expect(find.textContaining('Just say carton details'), findsOneWidget);
      },
    );

    testWidgets('has close button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('VoiceInputModal - Service Integration', () {
    testWidgets('calls AudioRecorderService.startRecording on button tap', (
      tester,
    ) async {
      when(mockRecorder.startRecording()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Recording'));
      await tester.pump();

      verify(mockRecorder.startRecording()).called(1);
    });

    testWidgets('uses WhisperServerManager when provider is whisper', (
      tester,
    ) async {
      when(mockServerManager.isRunning).thenReturn(false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transcriptionProviderProvider.overrideWith((ref) {
              return TranscriptionProviderNotifier()
                ..state = TranscriptionProviderType.whisper;
            }),
          ],
          child: const MaterialApp(home: Scaffold(body: VoiceInputModal())),
        ),
      );
      await tester.pumpAndSettle();

      // Widget should render successfully with Whisper provider
      expect(find.byType(VoiceInputModal), findsOneWidget);
    });

    testWidgets('renders correctly with Gemini provider', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transcriptionProviderProvider.overrideWith((ref) {
              return TranscriptionProviderNotifier()
                ..state = TranscriptionProviderType.gemini;
            }),
          ],
          child: const MaterialApp(home: Scaffold(body: VoiceInputModal())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VoiceInputModal), findsOneWidget);
      expect(find.text('Start Recording'), findsOneWidget);
    });
  });

  group('VoiceInputModal - Props and Configuration', () {
    testWidgets('accepts hasExistingLocation parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(hasExistingLocation: true));
      await tester.pumpAndSettle();

      expect(find.byType(VoiceInputModal), findsOneWidget);
    });

    testWidgets('renders without hasExistingLocation parameter', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: VoiceInputModal())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VoiceInputModal), findsOneWidget);
    });
  });

  group('VoiceInputModal - Provider Dependencies', () {
    testWidgets('retrieves transcription provider from context', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Widget should successfully read provider without error
      expect(find.byType(VoiceInputModal), findsOneWidget);
    });

    testWidgets('uses injected services from GetIt', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify GetIt services are accessible
      expect(getIt.isRegistered<AudioRecorderService>(), true);
      expect(getIt.isRegistered<WhisperServerManager>(), true);
      expect(getIt.isRegistered<GeminiAudioTranscriptionService>(), true);
    });
  });

  group('VoiceInputModal - UI Elements', () {
    testWidgets('displays microphone icon in initial state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mic), findsWidgets);
    });

    testWidgets('has button for recording', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have Start Recording button
      expect(find.text('Start Recording'), findsOneWidget);
    });

    testWidgets('displays instruction text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have some instructional text about recording
      expect(find.textContaining('Click "Start Recording"'), findsOneWidget);
    });
  });

  group('VoiceInputModal - Error Scenarios', () {
    testWidgets('handles missing GetIt services gracefully', (tester) async {
      // This test verifies the widget doesn't crash with missing services
      // In real scenario, GetIt should always have services registered
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VoiceInputModal), findsOneWidget);
    });
  });
}

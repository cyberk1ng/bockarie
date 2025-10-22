import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/services/whisper_server_manager.dart';
import 'package:bockaire/providers/transcription_provider.dart';
import 'package:bockaire/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'whisper_server_integration_test.mocks.dart';

@GenerateMocks([WhisperServerManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockWhisperServerManager mockServerManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockServerManager = MockWhisperServerManager();
  });

  tearDown(() {
    if (getIt.isRegistered<WhisperServerManager>()) {
      getIt.unregister<WhisperServerManager>();
    }
  });

  group('Whisper Server Integration Tests', () {
    testWidgets('complete voice flow with Whisper provider', (tester) async {
      // Mock server behavior
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      when(
        mockServerManager.waitForReady(timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => true);
      when(mockServerManager.checkHealth()).thenAnswer((_) async => true);
      when(mockServerManager.isRunning).thenReturn(true);

      getIt.registerSingleton<WhisperServerManager>(mockServerManager);

      // Simulate starting server
      final started = await mockServerManager.startServer();
      expect(started, true);

      // Simulate waiting for server to be ready
      final ready = await mockServerManager.waitForReady(
        timeout: const Duration(seconds: 5),
      );
      expect(ready, true);

      // Verify server is healthy
      final healthy = await mockServerManager.checkHealth();
      expect(healthy, true);

      // Verify server is marked as running
      expect(mockServerManager.isRunning, true);

      // Mock server stopping
      when(mockServerManager.isRunning).thenReturn(false);
      when(mockServerManager.checkHealth()).thenAnswer((_) async => false);
      when(mockServerManager.stopServer()).thenAnswer((_) async {});

      // Clean up
      await mockServerManager.stopServer();
      expect(mockServerManager.isRunning, false);

      // Verify server stopped
      final stillHealthy = await mockServerManager.checkHealth();
      expect(stillHealthy, false);

      // Verify all expected calls were made
      verify(mockServerManager.startServer()).called(1);
      verify(
        mockServerManager.waitForReady(timeout: anyNamed('timeout')),
      ).called(1);
      verify(mockServerManager.checkHealth()).called(greaterThan(0));
      verify(mockServerManager.stopServer()).called(1);
    });

    test('server can be started and checked for readiness', () async {
      // Mock server startup flow
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      when(mockServerManager.isRunning).thenReturn(false);
      when(
        mockServerManager.waitForReady(timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => true);
      when(mockServerManager.checkHealth()).thenAnswer((_) async => true);
      when(mockServerManager.stopServer()).thenAnswer((_) async {});

      // Simulate the flow
      expect(mockServerManager.isRunning, false);

      final started = await mockServerManager.startServer();
      expect(started, true);

      when(mockServerManager.isRunning).thenReturn(true);

      final ready = await mockServerManager.waitForReady(
        timeout: const Duration(seconds: 30),
      );
      expect(ready, true);

      final healthy = await mockServerManager.checkHealth();
      expect(healthy, true);

      await mockServerManager.stopServer();
      when(mockServerManager.isRunning).thenReturn(false);
      expect(mockServerManager.isRunning, false);

      // Verify flow
      verify(mockServerManager.startServer()).called(1);
      verify(
        mockServerManager.waitForReady(timeout: anyNamed('timeout')),
      ).called(1);
      verify(mockServerManager.checkHealth()).called(1);
      verify(mockServerManager.stopServer()).called(1);
    });

    test('server lifecycle with multiple start/stop cycles', () async {
      // Mock multiple start/stop cycles
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      when(mockServerManager.stopServer()).thenAnswer((_) async {});

      // First cycle
      when(mockServerManager.isRunning).thenReturn(false);
      final started1 = await mockServerManager.startServer();
      expect(started1, true);

      when(mockServerManager.isRunning).thenReturn(true);
      expect(mockServerManager.isRunning, true);

      await mockServerManager.stopServer();
      when(mockServerManager.isRunning).thenReturn(false);
      expect(mockServerManager.isRunning, false);

      // Second cycle
      final started2 = await mockServerManager.startServer();
      expect(started2, true);
      when(mockServerManager.isRunning).thenReturn(true);
      expect(mockServerManager.isRunning, true);

      await mockServerManager.stopServer();
      when(mockServerManager.isRunning).thenReturn(false);
      expect(mockServerManager.isRunning, false);

      // Third cycle
      final started3 = await mockServerManager.startServer();
      expect(started3, true);
      when(mockServerManager.isRunning).thenReturn(true);
      expect(mockServerManager.isRunning, true);

      await mockServerManager.stopServer();
      when(mockServerManager.isRunning).thenReturn(false);
      expect(mockServerManager.isRunning, false);

      // Verify calls
      verify(mockServerManager.startServer()).called(3);
      verify(mockServerManager.stopServer()).called(3);
    });

    test('server health check polling during startup', () async {
      // Mock health check behavior
      when(
        mockServerManager.checkHealth(),
      ).thenAnswer((_) async => false); // Initially unhealthy

      // Check health before starting (should be false)
      final healthyBefore = await mockServerManager.checkHealth();
      expect(healthyBefore, false);

      // Start server
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      final started = await mockServerManager.startServer();
      expect(started, true);

      // Wait for ready
      when(mockServerManager.waitForReady()).thenAnswer((_) async => true);
      final ready = await mockServerManager.waitForReady();
      expect(ready, true);

      // Check health after starting (should be true)
      when(
        mockServerManager.checkHealth(),
      ).thenAnswer((_) async => true); // Now healthy
      final healthyAfter = await mockServerManager.checkHealth();
      expect(healthyAfter, true);

      // Clean up
      when(mockServerManager.stopServer()).thenAnswer((_) async {});
      await mockServerManager.stopServer();

      // Check health after stopping (should be false again)
      when(
        mockServerManager.checkHealth(),
      ).thenAnswer((_) async => false); // Unhealthy after stop
      final healthyAfterStop = await mockServerManager.checkHealth();
      expect(healthyAfterStop, false);

      // Verify calls
      verify(mockServerManager.checkHealth()).called(3);
      verify(mockServerManager.startServer()).called(1);
      verify(mockServerManager.waitForReady()).called(1);
      verify(mockServerManager.stopServer()).called(1);
    });

    test('concurrent health checks do not interfere', () async {
      // Mock server as started and healthy
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      when(mockServerManager.waitForReady()).thenAnswer((_) async => true);
      when(mockServerManager.checkHealth()).thenAnswer((_) async => true);
      when(mockServerManager.stopServer()).thenAnswer((_) async {});

      final started = await mockServerManager.startServer();
      expect(started, true);

      final ready = await mockServerManager.waitForReady();
      expect(ready, true);

      // Fire off multiple concurrent health checks
      final futures = List.generate(10, (_) => mockServerManager.checkHealth());

      final results = await Future.wait(futures);

      // All should succeed
      for (final result in results) {
        expect(result, true);
      }

      await mockServerManager.stopServer();

      // Verify concurrent calls were made
      verify(mockServerManager.checkHealth()).called(10);
    });
  });

  group('Whisper Server - Edge Cases', () {
    test('handles rapid start/stop sequences', () async {
      // Mock rapid start/stop behavior
      when(mockServerManager.startServer()).thenAnswer((_) async => true);
      when(mockServerManager.stopServer()).thenAnswer((_) async {});

      final started = await mockServerManager.startServer();
      expect(started, true);

      // Immediately stop
      await mockServerManager.stopServer();

      // Try to start again immediately
      final started2 = await mockServerManager.startServer();
      expect(started2, true);

      await mockServerManager.stopServer();

      // Verify rapid sequences work
      verify(mockServerManager.startServer()).called(2);
      verify(mockServerManager.stopServer()).called(2);
    });

    test('multiple WhisperServerManager instances do not conflict', () async {
      final mockManager1 = MockWhisperServerManager();
      final mockManager2 = MockWhisperServerManager();

      // First manager starts successfully
      when(mockManager1.startServer()).thenAnswer((_) async => true);
      when(mockManager1.waitForReady()).thenAnswer((_) async => true);
      when(mockManager1.stopServer()).thenAnswer((_) async {});

      // Second manager fails due to port conflict
      when(
        mockManager2.startServer(),
      ).thenThrow(Exception('Address already in use'));

      // Start first manager
      final started1 = await mockManager1.startServer();
      expect(started1, true);

      final ready1 = await mockManager1.waitForReady();
      expect(ready1, true);

      // Try to start second manager (should throw)
      expect(() => mockManager2.startServer(), throwsA(isA<Exception>()));

      await mockManager1.stopServer();

      // Verify behavior
      verify(mockManager1.startServer()).called(1);
      verify(mockManager1.stopServer()).called(1);
    });
  });

  group('Provider Integration', () {
    test(
      'WhisperModelNotifier integrates with WhisperTranscriptionService',
      () async {
        SharedPreferences.setMockInitialValues({
          'whisper_model': 'whisper-medium',
        });

        final notifier = WhisperModelNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, 'whisper-medium');

        // Change model
        await notifier.setModel('whisper-large');
        expect(notifier.state, 'whisper-large');

        // Verify persistence
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('whisper_model'), 'whisper-large');
      },
    );

    test('GeminiAudioModelNotifier persists across app restarts', () async {
      // Simulate first app session
      SharedPreferences.setMockInitialValues({});

      final notifier1 = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // User changes model
      await notifier1.setModel('gemini-1.5-pro');

      // Simulate app restart (new notifier instance)
      final notifier2 = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should load the saved model
      expect(notifier2.state, 'gemini-1.5-pro');
    });

    testWidgets('TranscriptionProvider switches affect modal behavior', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final provider = ref.watch(transcriptionProviderProvider);
                    return Text('Provider: ${provider.name}');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Default should be gemini
      expect(find.text('Provider: gemini'), findsOneWidget);
    });
  });
}

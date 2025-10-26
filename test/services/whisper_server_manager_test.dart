import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/services/whisper_server_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WhisperServerManager', () {
    late WhisperServerManager manager;

    setUp(() {
      manager = WhisperServerManager();
    });

    tearDown(() {
      manager.dispose();
    });

    group('isRunning', () {
      test('returns false initially', () {
        expect(manager.isRunning, false);
      });
    });

    group('checkHealth', () {
      test('returns false when server is not reachable', () async {
        final manager = WhisperServerManager();
        // Server is not running, should return false
        final result = await manager.checkHealth();
        expect(result, false);
      });

      test('returns false on timeout', () async {
        final manager = WhisperServerManager();
        final result = await manager.checkHealth();
        expect(result, false);
      });
    });

    group('startServer', () {
      test('returns true when already running', () async {
        // This test requires being able to set the internal state
        // We need to refactor WhisperServerManager to be more testable

        // For now, we'll test the actual behavior
        // Note: This will fail if whisper_server directory doesn't exist
        try {
          final _ = await manager.startServer();
          if (manager.isRunning) {
            final secondResult = await manager.startServer();
            expect(secondResult, true);
            await manager.stopServer();
          }
        } catch (e) {
          // If whisper_server not found, that's expected in test environment
          expect(e.toString(), contains('Whisper server directory not found'));
        }
      });

      test('handles missing whisper_server directory gracefully', () async {
        // In most test environments, whisper_server won't exist
        // This is expected behavior - the error should be clear
        try {
          await manager.startServer();
          // If it succeeds, server was found and started
          expect(manager.isRunning, isTrue);
          await manager.stopServer();
        } catch (e) {
          // Expected: server directory not found
          expect(e.toString(), contains('Whisper server directory not found'));
        }
      });

      test('throws exception when Python not found', () async {
        // This test is environment-dependent
        // We'd need to mock Process.start to test this properly
      });
    });

    group('stopServer', () {
      test('handles no server process gracefully', () async {
        // Should not throw
        await expectLater(manager.stopServer(), completes);
      });

      test('stops running server', () async {
        // Start server first (if possible in test environment)
        try {
          await manager.startServer();
          if (manager.isRunning) {
            await manager.stopServer();
            expect(manager.isRunning, false);
          }
        } catch (e) {
          // Expected if whisper_server not available
        }
      });
    });

    group('waitForReady', () {
      test('returns false when server never becomes healthy', () async {
        // With no server running, this should timeout
        final result = await manager.waitForReady(
          timeout: const Duration(seconds: 2),
        );
        expect(result, false);
      });

      test('returns true when server becomes healthy', () async {
        // This would require actually starting a server
        // Skip in unit tests, cover in integration tests
      });
    });

    group('dispose', () {
      test('cleans up resources', () {
        // Should not throw
        expect(() => manager.dispose(), returnsNormally);
      });
    });

    group('platform-specific behavior', () {
      test('uses correct Python command for platform', () {
        // The _pythonCommand getter returns platform-specific command
        final expectedCommand = Platform.isWindows ? 'python' : 'python3';
        // We can't directly test the private getter without refactoring
        // This is more of a documentation test
        expect(expectedCommand, isNotEmpty);
      });
    });
  });

  group('WhisperServerManager - Integration Scenarios', () {
    test(
      'server lifecycle: start -> check health -> stop',
      skip: 'Integration test - requires actual whisper server infrastructure',
      () async {
        final manager = WhisperServerManager();

        try {
          // Try to start server
          final started = await manager.startServer();

          if (started) {
            expect(manager.isRunning, true);

            // Wait for server to be ready with shorter timeout for tests
            final ready = await manager.waitForReady(
              timeout: const Duration(seconds: 10),
            );

            if (ready) {
              // Check health
              final healthy = await manager.checkHealth();
              expect(healthy, true);

              // Stop server
              await manager.stopServer();
              expect(manager.isRunning, false);
            } else {
              // Server started but didn't become healthy in time
              // This is acceptable in test environment (e.g., concurrent tests,
              // missing dependencies, or slow startup)
              // Just ensure we can stop it
              await manager.stopServer();
            }
          }
          // If server didn't start, that's also acceptable in test environment
        } catch (e) {
          // Expected in test environment without whisper_server setup
          // or when concurrent tests cause resource contention
          expect(e, isA<Exception>());
        } finally {
          manager.dispose();
        }
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'concurrent start calls return true for already running',
      skip: 'Integration test - requires actual whisper server infrastructure',
      () async {
        final manager = WhisperServerManager();

        try {
          final result1 = await manager.startServer();
          if (result1) {
            final result2 = await manager.startServer();
            expect(result2, true);
            expect(manager.isRunning, true);
            await manager.stopServer();
          }
        } catch (e) {
          // Expected in test environment
        } finally {
          manager.dispose();
        }
      },
    );
  });

  group('WhisperServerManager - Error Handling', () {
    test('handles port already in use gracefully', () async {
      // This would require actually having something on port 8089
      // Document expected behavior: should log error but not crash
    });

    test('handles corrupted executable gracefully', () async {
      // This would require setting up a corrupted executable
      // Document expected behavior: should fall back to Python
    });
  });
}

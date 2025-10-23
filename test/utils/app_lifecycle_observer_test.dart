import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bockaire/utils/app_lifecycle_observer.dart';
import 'package:bockaire/services/whisper_server_manager.dart';
import 'package:bockaire/get_it.dart';

@GenerateMocks([WhisperServerManager])
import 'app_lifecycle_observer_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockWhisperServerManager mockServerManager;
  late AppLifecycleObserver observer;

  setUp(() {
    mockServerManager = MockWhisperServerManager();

    // Setup GetIt mock
    if (getIt.isRegistered<WhisperServerManager>()) {
      getIt.unregister<WhisperServerManager>();
    }
    getIt.registerSingleton<WhisperServerManager>(mockServerManager);

    observer = AppLifecycleObserver();
  });

  tearDown(() {
    getIt.reset();
  });

  group('AppLifecycleObserver', () {
    test('calls stopServer when app state is detached', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      observer.didChangeAppLifecycleState(AppLifecycleState.detached);

      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockServerManager.stopServer()).called(1);
    });

    test('does not call stopServer when app state is paused', () async {
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockServerManager.stopServer());
    });

    test('does not call stopServer when app state is resumed', () async {
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockServerManager.stopServer());
    });

    test('does not call stopServer when app state is inactive', () async {
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockServerManager.stopServer());
    });

    test('does not call stopServer when app state is hidden', () async {
      observer.didChangeAppLifecycleState(AppLifecycleState.hidden);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockServerManager.stopServer());
    });

    test('handles detached when server is not running', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      // Should not throw
      expect(
        () => observer.didChangeAppLifecycleState(AppLifecycleState.detached),
        returnsNormally,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockServerManager.stopServer()).called(1);
    });

    test('handles multiple detached events', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      observer.didChangeAppLifecycleState(AppLifecycleState.detached);
      observer.didChangeAppLifecycleState(AppLifecycleState.detached);
      observer.didChangeAppLifecycleState(AppLifecycleState.detached);

      await Future.delayed(const Duration(milliseconds: 100));

      // Should be called 3 times (one for each event)
      verify(mockServerManager.stopServer()).called(3);
    });
  });

  group('AppLifecycleObserver - Integration', () {
    test('observer can be created and called directly', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      final observer = AppLifecycleObserver();

      // Call lifecycle method directly
      observer.didChangeAppLifecycleState(AppLifecycleState.detached);

      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockServerManager.stopServer()).called(1);
    });

    test('multiple observers can coexist', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      final observer1 = AppLifecycleObserver();
      final observer2 = AppLifecycleObserver();

      observer1.didChangeAppLifecycleState(AppLifecycleState.detached);
      observer2.didChangeAppLifecycleState(AppLifecycleState.detached);

      await Future.delayed(const Duration(milliseconds: 100));

      // Should be called twice (once per observer)
      verify(mockServerManager.stopServer()).called(2);
    });
  });

  group('AppLifecycleObserver - All Lifecycle States', () {
    test('handles complete lifecycle transition', () async {
      when(mockServerManager.stopServer()).thenAnswer((_) async => {});

      // Simulate app lifecycle: resumed -> inactive -> paused -> detached
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      verifyNever(mockServerManager.stopServer());

      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      verifyNever(mockServerManager.stopServer());

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      verifyNever(mockServerManager.stopServer());

      observer.didChangeAppLifecycleState(AppLifecycleState.detached);
      await Future.delayed(const Duration(milliseconds: 100));
      verify(mockServerManager.stopServer()).called(1);
    });
  });
}

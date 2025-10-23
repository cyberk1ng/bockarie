import 'package:flutter/material.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/services/whisper_server_manager.dart';

/// Observes app lifecycle events and manages server shutdown
class AppLifecycleObserver extends WidgetsBindingObserver {
  final WhisperServerManager _serverManager = getIt<WhisperServerManager>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is closing, stop server
      _serverManager.stopServer();
    }
  }
}

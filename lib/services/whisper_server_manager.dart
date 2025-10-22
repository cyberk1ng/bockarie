import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

/// Manages the lifecycle of the local Whisper server
class WhisperServerManager {
  Process? _serverProcess;
  bool _isRunning = false;
  final Logger _logger = Logger();
  final http.Client _httpClient = http.Client();

  static const String _baseUrl = 'http://127.0.0.1:8089';
  static const String _healthEndpoint = '/health';

  /// Check if server is currently running
  bool get isRunning => _isRunning;

  /// Get the appropriate Python command for the current platform
  String get _pythonCommand => Platform.isWindows ? 'python' : 'python3';

  /// Find the whisper_server directory by checking multiple locations
  String? _findWhisperServerDir() {
    final searchPaths = <String>[];

    // 1. Current directory (for sandboxed apps this might be container)
    searchPaths.add(path.join(Directory.current.path, 'whisper_server'));

    // 2. Project directory (for development) - try to go up from executable
    final executablePath = Platform.resolvedExecutable;
    final executableDir = path.dirname(executablePath);

    // For macOS debug builds, executable is usually in build/macos/Build/Products/Debug/
    // So we need to go up several levels to reach project root
    var currentDir = executableDir;
    for (var i = 0; i < 10; i++) {
      final testPath = path.join(currentDir, 'whisper_server');
      if (!searchPaths.contains(testPath)) {
        searchPaths.add(testPath);
      }
      final parentDir = path.dirname(currentDir);
      if (parentDir == currentDir) break; // Reached root
      currentDir = parentDir;
    }

    // 3. Next to the executable (for bundled apps)
    searchPaths.add(path.join(executableDir, 'whisper_server'));

    // 4. In Resources (for macOS bundles)
    if (Platform.isMacOS) {
      searchPaths.add(
        path.join(executableDir, '..', 'Resources', 'whisper_server'),
      );
    }

    _logger.d('Searching for whisper_server in: $searchPaths');

    for (final searchPath in searchPaths) {
      final normalizedPath = path.normalize(searchPath);
      if (Directory(normalizedPath).existsSync()) {
        _logger.i('Found whisper_server at: $normalizedPath');
        return normalizedPath;
      }
    }

    return null;
  }

  /// Get the path to the bundled executable (if it exists)
  String? _getExecutablePath(String serverDir) {
    final distPath = path.join(serverDir, 'dist', 'whisper_api_server');
    final execPath = Platform.isWindows ? '$distPath.exe' : distPath;
    return File(execPath).existsSync() ? execPath : null;
  }

  /// Start the Whisper server as a subprocess
  Future<bool> startServer() async {
    if (_isRunning) {
      _logger.i('Whisper server already running');
      return true;
    }

    try {
      // Find the whisper_server directory
      final workingDir = _findWhisperServerDir();

      if (workingDir == null) {
        _logger.e('Whisper server directory not found in any search locations');
        throw Exception('Whisper server directory not found');
      }

      String executable;
      List<String> arguments;

      // Try bundled executable first, fallback to Python
      final executablePath = _getExecutablePath(workingDir);
      if (executablePath != null) {
        _logger.i('Starting bundled Whisper server: $executablePath');
        executable = executablePath;
        arguments = [];
      } else {
        _logger.i('Starting Whisper server with Python: $_pythonCommand');
        executable = _pythonCommand;
        arguments = ['whisper_api_server.py'];
      }

      _logger.d('Working directory: $workingDir');
      _logger.d('Command: $executable ${arguments.join(" ")}');

      _serverProcess = await Process.start(
        executable,
        arguments,
        workingDirectory: workingDir,
        environment: {'PYTHONUNBUFFERED': '1'},
        runInShell: true,
      );

      // Listen to stdout for debugging
      _serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        _logger.d('[Whisper Server] $data');
      });

      // Listen to stderr for errors
      _serverProcess!.stderr.transform(utf8.decoder).listen((data) {
        _logger.w('[Whisper Server Error] $data');

        if (data.contains('Address already in use')) {
          _logger.e('Port 8089 already in use');
        }
      });

      // Handle process exit
      _serverProcess!.exitCode.then((exitCode) {
        _logger.i('Whisper server exited with code: $exitCode');
        _isRunning = false;
        _serverProcess = null;
      });

      _isRunning = true;
      _logger.i('Whisper server process started');
      return true;
    } catch (e) {
      _logger.e('Failed to start Whisper server: $e');
      _isRunning = false;
      _serverProcess = null;

      if (e.toString().contains('No such file or directory') ||
          e.toString().contains('not found')) {
        throw Exception(
          'Python not found. Please install Python 3.8+ or use Gemini provider.',
        );
      }

      throw Exception('Failed to start Whisper server: $e');
    }
  }

  /// Stop the server gracefully
  Future<void> stopServer() async {
    if (_serverProcess == null) {
      _logger.i('No server process to stop');
      return;
    }

    try {
      _logger.i('Stopping Whisper server...');
      _serverProcess!.kill(ProcessSignal.sigterm);

      // Wait for process to exit (with timeout)
      await _serverProcess!.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _logger.w('Server did not stop gracefully, forcing kill');
          _serverProcess!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );

      _serverProcess = null;
      _isRunning = false;
      _logger.i('Whisper server stopped');
    } catch (e) {
      _logger.e('Error stopping Whisper server: $e');
      _serverProcess = null;
      _isRunning = false;
    }
  }

  /// Check server health without starting
  Future<bool> checkHealth() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl$_healthEndpoint'))
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      _logger.d('Health check failed: $e');
      return false;
    }
  }

  /// Wait for server to be ready (polls health endpoint)
  Future<bool> waitForReady({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final endTime = DateTime.now().add(timeout);
    int attempt = 0;

    _logger.i('Waiting for Whisper server to be ready...');

    while (DateTime.now().isBefore(endTime)) {
      attempt++;
      _logger.d('Health check attempt $attempt');

      if (await checkHealth()) {
        _logger.i('Whisper server is ready!');
        return true;
      }

      // Exponential backoff with max 2 seconds
      final delay = Duration(
        milliseconds: (500 * (attempt < 4 ? 1 : 2)).toInt(),
      );
      await Future.delayed(delay);
    }

    _logger.e(
      'Whisper server failed to start within ${timeout.inSeconds} seconds',
    );
    return false;
  }

  /// Cleanup resources
  void dispose() {
    _httpClient.close();
    stopServer();
  }
}

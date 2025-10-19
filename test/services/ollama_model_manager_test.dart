import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bockaire/services/ollama_model_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late OllamaModelManager manager;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(Uri.parse('http://localhost:11434/api/tags'));
    registerFallbackValue(http.Request('POST', Uri.parse('http://test')));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    manager = OllamaModelManager(
      baseUrl: 'http://localhost:11434',
      httpClient: mockHttpClient,
    );
  });

  group('OllamaModelManager - Server Availability', () {
    test('isServerAvailable returns true when server responds 200', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('{}', 200));

      final result = await manager.isServerAvailable();

      expect(result, true);
      verify(
        () => mockHttpClient.get(Uri.parse('http://localhost:11434/api/tags')),
      ).called(1);
    });

    test('isServerAvailable returns false on timeout', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 10),
          () => http.Response('{}', 200),
        ),
      );

      final result = await manager.isServerAvailable();

      expect(result, false);
    });

    test('isServerAvailable returns false on connection error', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenThrow(SocketException('Connection refused'));

      final result = await manager.isServerAvailable();

      expect(result, false);
    });

    test('isServerAvailable returns false on non-200 response', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('Server error', 500));

      final result = await manager.isServerAvailable();

      expect(result, false);
    });
  });

  group('OllamaModelManager - Model Installation Check', () {
    test('isModelInstalled returns true when model exists', () async {
      final responseBody = jsonEncode({
        'models': [
          {
            'name': 'llava:13b',
            'size': 7365960935,
            'modified_at': '2024-01-01T00:00:00Z',
          },
          {
            'name': 'minicpm-v:8b',
            'size': 5000000000,
            'modified_at': '2024-01-01T00:00:00Z',
          },
        ],
      });

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, true);
    });

    test('isModelInstalled returns false when model not in list', () async {
      final responseBody = jsonEncode({
        'models': [
          {
            'name': 'llava:13b',
            'size': 7365960935,
            'modified_at': '2024-01-01T00:00:00Z',
          },
        ],
      });

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.isModelInstalled('minicpm-v:8b');

      expect(result, false);
    });

    test('isModelInstalled handles empty model list', () async {
      final responseBody = jsonEncode({'models': []});

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });

    test('isModelInstalled handles missing models field', () async {
      final responseBody = jsonEncode({});

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });

    test('isModelInstalled returns false on non-200 response', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });

    test('isModelInstalled handles malformed API response', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('invalid json', 200));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });

    test('isModelInstalled handles network errors', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenThrow(SocketException('Connection refused'));

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });

    test('isModelInstalled handles timeout', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 15),
          () => http.Response('{}', 200),
        ),
      );

      final result = await manager.isModelInstalled('llava:13b');

      expect(result, false);
    });
  });

  group('OllamaModelManager - Model Listing', () {
    test('getInstalledModels returns list of ModelInfo', () async {
      final responseBody = jsonEncode({
        'models': [
          {
            'name': 'llava:13b',
            'size': 7365960935,
            'modified_at': '2024-01-01T00:00:00Z',
          },
          {
            'name': 'minicpm-v:8b',
            'size': 5000000000,
            'modified_at': '2024-01-02T00:00:00Z',
          },
        ],
      });

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.getInstalledModels();

      expect(result, hasLength(2));
      expect(result[0].name, 'llava:13b');
      expect(result[0].size, 7365960935);
      expect(result[0].modifiedAt, '2024-01-01T00:00:00Z');
      expect(result[1].name, 'minicpm-v:8b');
    });

    test('getInstalledModels handles empty list', () async {
      final responseBody = jsonEncode({'models': []});

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.getInstalledModels();

      expect(result, isEmpty);
    });

    test('getInstalledModels parses size correctly', () async {
      final responseBody = jsonEncode({
        'models': [
          {
            'name': 'llava:13b',
            'size': 7365960935,
            'modified_at': '2024-01-01T00:00:00Z',
          },
        ],
      });

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.getInstalledModels();

      expect(result[0].sizeInGB, '6.86 GB');
    });

    test('getInstalledModels handles missing size field', () async {
      final responseBody = jsonEncode({
        'models': [
          {'name': 'llava:13b', 'modified_at': '2024-01-01T00:00:00Z'},
        ],
      });

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.getInstalledModels();

      expect(result[0].size, 0);
    });

    test('getInstalledModels throws on non-200 response', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => manager.getInstalledModels(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to get models: 500'),
          ),
        ),
      );
    });

    test('getInstalledModels handles missing models field', () async {
      final responseBody = jsonEncode({});

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await manager.getInstalledModels();

      expect(result, isEmpty);
    });
  });

  group('OllamaModelManager - Model Installation', () {
    test('installModel yields progress updates', () async {
      final chunks = [
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 100}),
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 500}),
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 1000}),
        jsonEncode({'status': 'success', 'total': 1000, 'completed': 1000}),
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('llava:13b').toList();

      expect(progressList, hasLength(4));
      expect(progressList[0].status, 'downloading');
      expect(progressList[0].completed, 100);
      expect(progressList[0].total, 1000);
      expect(progressList[0].progress, 0.1);
      expect(progressList[1].completed, 500);
      expect(progressList[1].progress, 0.5);
      expect(progressList[3].status, 'success');
    });

    test('installModel completes on success status', () async {
      final chunks = [
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 500}),
        jsonEncode({'status': 'success', 'total': 1000, 'completed': 1000}),
        jsonEncode({'status': 'extra', 'total': 1000, 'completed': 1000}),
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('llava:13b').toList();

      // Should stop after 'success' status
      expect(progressList, hasLength(2));
      expect(progressList[1].status, 'success');
    });

    test('installModel handles network errors', () async {
      when(
        () => mockHttpClient.send(any()),
      ).thenThrow(SocketException('Connection refused'));

      expect(
        () => manager.installModel('llava:13b').toList(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Cannot connect to Ollama server'),
          ),
        ),
      );
    });

    test('installModel handles non-200 responses', () async {
      final stream = Stream.fromIterable([utf8.encode('Error')]);

      final streamedResponse = http.StreamedResponse(
        stream,
        500,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      expect(
        () => manager.installModel('llava:13b').toList(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Failed to start model installation: 500',
                ),
          ),
        ),
      );
    });

    test('installModel parses progress JSON chunks', () async {
      final chunks = [
        jsonEncode({'status': 'pulling manifest', 'total': 0, 'completed': 0}),
        jsonEncode({
          'status': 'downloading digestabc123',
          'total': 5000000000,
          'completed': 1000000000,
        }),
        jsonEncode({
          'status': 'verifying sha256 digest',
          'total': 0,
          'completed': 0,
        }),
        jsonEncode({
          'status': 'success',
          'total': 5000000000,
          'completed': 5000000000,
        }),
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('minicpm-v:8b').toList();

      expect(progressList, hasLength(4));
      expect(progressList[0].status, 'pulling manifest');
      expect(progressList[1].status, 'downloading digestabc123');
      expect(progressList[2].status, 'verifying sha256 digest');
      expect(progressList[3].status, 'success');
    });

    test('installModel handles empty chunks gracefully', () async {
      final chunks = [
        '',
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 500}),
        '',
        jsonEncode({'status': 'success', 'total': 1000, 'completed': 1000}),
        '',
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('llava:13b').toList();

      // Should only include valid chunks
      expect(progressList, hasLength(2));
    });

    test('installModel handles malformed JSON chunks', () async {
      final chunks = [
        jsonEncode({'status': 'downloading', 'total': 1000, 'completed': 100}),
        'invalid json',
        jsonEncode({'status': 'success', 'total': 1000, 'completed': 1000}),
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('llava:13b').toList();

      // Should skip malformed chunk
      expect(progressList, hasLength(2));
      expect(progressList[0].status, 'downloading');
      expect(progressList[1].status, 'success');
    });

    test('installModel handles missing fields in JSON', () async {
      final chunks = [
        jsonEncode({'status': 'downloading'}),
        jsonEncode({'total': 1000, 'completed': 500}),
        jsonEncode({'status': 'success'}),
      ];

      final stream = Stream.fromIterable(
        chunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/pull'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final progressList = await manager.installModel('llava:13b').toList();

      expect(progressList, hasLength(3));
      expect(progressList[0].status, 'downloading');
      expect(progressList[0].total, 0);
      expect(progressList[0].completed, 0);
      expect(progressList[1].status, 'Processing...');
      expect(progressList[2].status, 'success');
    });
  });

  group('OllamaModelManager - Model Deletion', () {
    test('deleteModel succeeds with 200 response', () async {
      when(
        () => mockHttpClient.delete(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await manager.deleteModel('llava:13b');

      verify(
        () => mockHttpClient.delete(
          Uri.parse('http://localhost:11434/api/delete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': 'llava:13b'}),
        ),
      ).called(1);
    });

    test('deleteModel throws on non-200 response', () async {
      when(
        () => mockHttpClient.delete(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Model not found', 404));

      expect(
        () => manager.deleteModel('llava:13b'),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to delete model: 404'),
          ),
        ),
      );
    });

    test('deleteModel handles network errors', () async {
      when(
        () => mockHttpClient.delete(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(SocketException('Connection refused'));

      expect(
        () => manager.deleteModel('llava:13b'),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('OllamaModelManager - Model Warmup', () {
    test('warmUpModel completes successfully', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await manager.warmUpModel('llava:13b');

      verify(
        () => mockHttpClient.post(
          Uri.parse('http://localhost:11434/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: any(named: 'body'),
        ),
      ).called(1);
    });

    test('warmUpModel handles timeout gracefully', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      // Should not throw, just log warning
      await manager.warmUpModel('llava:13b');
    });

    test('warmUpModel handles network errors gracefully', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(SocketException('Connection refused'));

      // Should not throw, just log warning
      await manager.warmUpModel('llava:13b');
    });

    test('warmUpModel sends correct request body', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await manager.warmUpModel('llava:13b');

      final captured = verify(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;

      final requestBody = jsonDecode(captured.first as String);
      expect(requestBody['model'], 'llava:13b');
      expect(requestBody['stream'], false);
      expect(requestBody['messages'], hasLength(1));
      expect(requestBody['messages'][0]['role'], 'user');
      expect(requestBody['messages'][0]['content'], 'Hello');
    });
  });

  group('OllamaModelManager - Static Data', () {
    test('recommendedVisionModels returns expected list', () {
      final models = OllamaModelManager.recommendedVisionModels;

      expect(models, hasLength(3));
      expect(models, contains('llava:13b'));
      expect(models, contains('minicpm-v:8b'));
      expect(models, contains('bakllava:7b'));
    });
  });

  group('ModelInfo - Data Class', () {
    test('fromJson creates ModelInfo correctly', () {
      final json = {
        'name': 'llava:13b',
        'size': 7365960935,
        'modified_at': '2024-01-01T00:00:00Z',
      };

      final modelInfo = ModelInfo.fromJson(json);

      expect(modelInfo.name, 'llava:13b');
      expect(modelInfo.size, 7365960935);
      expect(modelInfo.modifiedAt, '2024-01-01T00:00:00Z');
    });

    test('fromJson handles missing size', () {
      final json = {'name': 'llava:13b', 'modified_at': '2024-01-01T00:00:00Z'};

      final modelInfo = ModelInfo.fromJson(json);

      expect(modelInfo.size, 0);
    });

    test('fromJson handles missing modified_at', () {
      final json = {'name': 'llava:13b', 'size': 7365960935};

      final modelInfo = ModelInfo.fromJson(json);

      expect(modelInfo.modifiedAt, '');
    });

    test('sizeInGB formats correctly', () {
      final modelInfo = ModelInfo(
        name: 'llava:13b',
        size: 7365960935,
        modifiedAt: '2024-01-01T00:00:00Z',
      );

      expect(modelInfo.sizeInGB, '6.86 GB');
    });
  });

  group('ModelInstallProgress - Data Class', () {
    test('progress calculates correctly', () {
      final progress = ModelInstallProgress(
        status: 'downloading',
        total: 1000,
        completed: 250,
      );

      expect(progress.progress, 0.25);
      expect(progress.percentage, '25.0%');
    });

    test('progress handles zero total', () {
      final progress = ModelInstallProgress(
        status: 'initializing',
        total: 0,
        completed: 0,
      );

      expect(progress.progress, 0.0);
      expect(progress.percentage, '0.0%');
    });

    test('toString formats correctly', () {
      final progress = ModelInstallProgress(
        status: 'downloading',
        total: 1000,
        completed: 750,
      );

      expect(progress.toString(), 'downloading - 75.0%');
    });
  });
}

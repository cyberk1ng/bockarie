import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bockaire/services/ollama_packing_list_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

void main() {
  late MockHttpClient mockHttpClient;
  late OllamaPackingListService service;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(Uri.parse('http://localhost:11434/api/chat'));
    registerFallbackValue(http.Request('POST', Uri.parse('http://test')));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    service = OllamaPackingListService(
      baseUrl: 'http://localhost:11434',
      model: 'llava:13b',
      httpClient: mockHttpClient,
    );
  });

  group('OllamaPackingListService - Basic Properties', () {
    test('name returns correct format', () {
      expect(service.name, 'Ollama Vision (llava:13b)');
    });

    test('isAvailable returns true when baseUrl and model are not empty', () {
      expect(service.isAvailable, true);
    });

    test('isAvailable returns false when baseUrl is empty', () {
      final emptyService = OllamaPackingListService(
        baseUrl: '',
        model: 'llava:13b',
        httpClient: mockHttpClient,
      );
      expect(emptyService.isAvailable, false);
    });

    test('isAvailable returns false when model is empty', () {
      final emptyService = OllamaPackingListService(
        baseUrl: 'http://localhost:11434',
        model: '',
        httpClient: mockHttpClient,
      );
      expect(emptyService.isAvailable, false);
    });
  });

  group('OllamaPackingListService - Successful Extraction', () {
    test('successfully extracts cartons from valid array response', () async {
      // Create a test image file
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG header

      // Mock response chunks
      final responseChunks = [
        jsonEncode({
          'message': {'content': '['},
          'done': false,
        }),
        jsonEncode({
          'message': {
            'content':
                '{"lengthCm": 50, "widthCm": 30, "heightCm": 20, "weightKg": 5.0, "qty": 10, "itemType": "Laptops"},',
          },
          'done': false,
        }),
        jsonEncode({
          'message': {
            'content':
                '{"lengthCm": 40, "widthCm": 40, "heightCm": 30, "weightKg": 8.5, "qty": 5, "itemType": "Monitors"}',
          },
          'done': false,
        }),
        jsonEncode({
          'message': {'content': ']'},
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(2));
      expect(result[0].lengthCm, 50);
      expect(result[0].widthCm, 30);
      expect(result[0].heightCm, 20);
      expect(result[0].weightKg, 5.0);
      expect(result[0].qty, 10);
      expect(result[0].itemType, 'Laptops');
      expect(result[1].lengthCm, 40);
      expect(result[1].itemType, 'Monitors');

      await tempDir.delete(recursive: true);
    });

    test('extracts cartons from object with cartons key', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {
            'content': jsonEncode({
              'cartons': [
                {
                  'lengthCm': 50,
                  'widthCm': 30,
                  'heightCm': 20,
                  'weightKg': 5.0,
                  'qty': 10,
                  'itemType': 'Boxes',
                },
              ],
            }),
          },
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(1));
      expect(result[0].itemType, 'Boxes');

      await tempDir.delete(recursive: true);
    });

    test('extracts cartons from object with items key', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {
            'content': jsonEncode({
              'items': [
                {
                  'lengthCm': 30,
                  'widthCm': 20,
                  'heightCm': 10,
                  'weightKg': 2.5,
                  'qty': 5,
                  'itemType': 'Packages',
                },
              ],
            }),
          },
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(1));
      expect(result[0].itemType, 'Packages');

      await tempDir.delete(recursive: true);
    });

    test('extracts cartons from object with data key', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {
            'content': jsonEncode({
              'data': [
                {
                  'lengthCm': 60,
                  'widthCm': 40,
                  'heightCm': 30,
                  'weightKg': 10.0,
                  'qty': 3,
                  'itemType': 'Crates',
                },
              ],
            }),
          },
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(1));
      expect(result[0].itemType, 'Crates');

      await tempDir.delete(recursive: true);
    });

    test('wraps single object in array when no known key found', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {
            'content': jsonEncode({
              'lengthCm': 50,
              'widthCm': 30,
              'heightCm': 20,
              'weightKg': 5.0,
              'qty': 1,
              'itemType': 'Single',
            }),
          },
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(1));
      expect(result[0].itemType, 'Single');

      await tempDir.delete(recursive: true);
    });
  });

  group('OllamaPackingListService - Error Handling', () {
    test(
      'throws ModelNotInstalledException on 404 with model in body',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('test_');
        final imageFile = File('${tempDir.path}/test_image.jpg');
        await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

        final stream = Stream.fromIterable([
          utf8.encode('model "llava:13b" not found'),
        ]);

        final streamedResponse = http.StreamedResponse(
          stream,
          404,
          request: http.Request(
            'POST',
            Uri.parse('http://localhost:11434/api/chat'),
          ),
        );

        when(() => mockHttpClient.send(any())).thenAnswer((_) async {
          return streamedResponse;
        });

        expect(
          () => service.extractCartonsFromImage(imageFile),
          throwsA(isA<ModelNotInstalledException>()),
        );

        await tempDir.delete(recursive: true);
      },
    );

    test('throws Exception on non-200 response', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final stream = Stream.fromIterable([utf8.encode('Server error')]);

      final streamedResponse = http.StreamedResponse(
        stream,
        500,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      expect(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Ollama API error: 500'),
          ),
        ),
      );

      await tempDir.delete(recursive: true);
    });

    test('handles empty response', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {'content': ''},
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      expect(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('No response from Ollama'),
          ),
        ),
      );

      await tempDir.delete(recursive: true);
    });

    test('handles malformed JSON in response', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {'content': '{invalid json'},
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      expect(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(isA<FormatException>()),
      );

      await tempDir.delete(recursive: true);
    });

    test('throws Exception on SocketException after retries', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      when(
        () => mockHttpClient.send(any()),
      ).thenThrow(SocketException('Connection refused'));

      await expectLater(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Cannot connect to Ollama server'),
          ),
        ),
      );

      // Should retry 3 times
      verify(() => mockHttpClient.send(any())).called(3);

      await tempDir.delete(recursive: true);
    });

    test('throws Exception on TimeoutException after retries', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      when(
        () => mockHttpClient.send(any()),
      ).thenThrow(TimeoutException('Request timed out'));

      await expectLater(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Request timed out after 120 seconds'),
          ),
        ),
      );

      // Should retry 3 times
      verify(() => mockHttpClient.send(any())).called(3);

      await tempDir.delete(recursive: true);
    });

    test('handles incomplete stream with empty chunks', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        '',
        jsonEncode({
          'message': {'content': '[]'},
          'done': true,
        }),
        '',
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, isEmpty);

      await tempDir.delete(recursive: true);
    });

    test('throws on unexpected JSON type', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      final responseChunks = [
        jsonEncode({
          'message': {'content': '"just a string"'},
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      expect(
        () => service.extractCartonsFromImage(imageFile),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('Unexpected JSON type'),
          ),
        ),
      );

      await tempDir.delete(recursive: true);
    });
  });

  group('OllamaPackingListService - Retry Logic', () {
    test('retries on SocketException with exponential backoff', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      int attempts = 0;
      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        attempts++;
        if (attempts < 3) {
          throw SocketException('Connection refused');
        }

        final responseChunks = [
          jsonEncode({
            'message': {'content': '[]'},
            'done': true,
          }),
        ];

        final stream = Stream.fromIterable(
          responseChunks.map((chunk) => utf8.encode('$chunk\n')),
        );

        return http.StreamedResponse(
          stream,
          200,
          request: http.Request(
            'POST',
            Uri.parse('http://localhost:11434/api/chat'),
          ),
        );
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, isEmpty);
      expect(attempts, 3);

      await tempDir.delete(recursive: true);
    });

    test('retries on TimeoutException with exponential backoff', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      await imageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      int attempts = 0;
      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        attempts++;
        if (attempts < 2) {
          throw TimeoutException('Request timed out');
        }

        final responseChunks = [
          jsonEncode({
            'message': {
              'content': jsonEncode([
                {
                  'lengthCm': 50,
                  'widthCm': 30,
                  'heightCm': 20,
                  'weightKg': 5.0,
                  'qty': 1,
                  'itemType': 'Box',
                },
              ]),
            },
            'done': true,
          }),
        ];

        final stream = Stream.fromIterable(
          responseChunks.map((chunk) => utf8.encode('$chunk\n')),
        );

        return http.StreamedResponse(
          stream,
          200,
          request: http.Request(
            'POST',
            Uri.parse('http://localhost:11434/api/chat'),
          ),
        );
      });

      final result = await service.extractCartonsFromImage(imageFile);

      expect(result, hasLength(1));
      expect(attempts, 2);

      await tempDir.delete(recursive: true);
    });
  });

  group('OllamaPackingListService - Base64 Encoding', () {
    test('correctly encodes image to base64', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final imageFile = File('${tempDir.path}/test_image.jpg');
      final testBytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10];
      await imageFile.writeAsBytes(testBytes);

      final responseChunks = [
        jsonEncode({
          'message': {'content': '[]'},
          'done': true,
        }),
      ];

      final stream = Stream.fromIterable(
        responseChunks.map((chunk) => utf8.encode('$chunk\n')),
      );

      final streamedResponse = http.StreamedResponse(
        stream,
        200,
        request: http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        ),
      );

      when(() => mockHttpClient.send(any())).thenAnswer((_) async {
        return streamedResponse;
      });

      await service.extractCartonsFromImage(imageFile);

      // Verify the request was sent
      final captured = verify(() => mockHttpClient.send(captureAny())).captured;
      expect(captured, hasLength(1));

      final request = captured.first as http.Request;
      final bodyJson = jsonDecode(request.body) as Map<String, dynamic>;
      final messages = bodyJson['messages'] as List;
      final firstMessage = messages[0] as Map<String, dynamic>;
      final images = firstMessage['images'] as List;

      // Verify base64 encoding
      expect(images[0], base64Encode(testBytes));

      await tempDir.delete(recursive: true);
    });
  });
}

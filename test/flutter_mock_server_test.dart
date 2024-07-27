import 'package:flutter_client_sse_validation/server.dart';
import 'package:flutter_client_sse_validation/simple_sse_client.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    createMockServer();
  });

  test('Mock SSE stream with real HTTP server', () async {
    final client = SimpleSseClient();

    // Act
    final sseStream = client.getStrings('sse');

    // Assert
    final expectedEvents = [
      'Hello World 1',
      'Hello World 2',
    ];

    final actualEvents = await sseStream.take(expectedEvents.length).toList();
    expect(actualEvents, expectedEvents);
  });

  test('SSE stuck due to 401 response', () async {
    final client = SimpleSseClient();

    // Act
    final sseStream = client.getStrings('401/sse');

    // Assert

    // Use expectLater to check that the stream emits an error
    expectLater(
      sseStream,
      emitsInOrder([
        emitsError(isA<Exception>()),
        emitsDone,
      ]),
    );
  });
}

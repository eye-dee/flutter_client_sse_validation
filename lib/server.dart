import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

Future<HttpServer> createMockServer() async {
  final router = Router();

  router.get('/sse', (Request request) {
    final controller = StreamController<List<int>>();

    // Simulate SSE events
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (timer.tick > 2) {
        controller.close();
        timer.cancel();
      } else {
        final event = 'Hello World ${timer.tick}';
        controller.add(utf8.encode('data: $event\n\n'));
      }
    });

    return Response.ok(
      controller.stream,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    );
  });

  router.get('/401/sse', (Request request) {
    return Response.unauthorized(
      null,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    );
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  return shelf_io.serve(handler, 'localhost', 8080);
}

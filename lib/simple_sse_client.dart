import 'dart:async';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:logger/logger.dart';

class SimpleSseClient {
  final String serverUrl = 'http://localhost:8080';

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  Stream<String> getStrings(String path) {
    final url = '$serverUrl/$path';

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    };

    return SSEClient.subscribeToSSE(
      url: url,
      method: SSERequestType.GET,
      header: headers,
      body: {},
    ).handleError((err) {
      logger.i("failed requesting topics $err");
    }).map<String>((SSEModel model) {
      if (model.data != null) {
        return model.data!.replaceFirst('data:', '').trim();
      }
      return '';
    });
  }
}

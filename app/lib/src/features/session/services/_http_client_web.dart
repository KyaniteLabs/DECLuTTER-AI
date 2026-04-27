import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Web-compatible HTTP client shim using package:http.
///
/// Mirrors the dart:io HttpClient API surface so that
/// [CashToClearApiClient] and [ValuationService] compile and run on web
/// without code changes.
class ContentType {
  static const String json = 'application/json';
}

class HttpHeaders {
  static const String authorizationHeader = 'authorization';
  final Map<String, String> _headers = {};

  String? get contentType => _headers['content-type'];

  set contentType(String? value) {
    if (value != null) {
      _headers['content-type'] = value;
    } else {
      _headers.remove('content-type');
    }
  }

  void set(String name, String value) {
    _headers[name.toLowerCase()] = value;
  }

  Map<String, String> toMap() => Map.unmodifiable(_headers);
}

class HttpClient {
  HttpClient();
  Duration? connectionTimeout;
  Duration idleTimeout = const Duration(seconds: 15);

  void close({bool force = false}) {}

  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return HttpClientRequest(method: method, url: url);
  }
}

class HttpClientRequest {
  HttpClientRequest({required this.method, required this.url});

  final String method;
  final Uri url;
  final HttpHeaders headers = HttpHeaders();
  final List<int> _bodyBytes = [];

  void write(Object? object) {
    if (object != null) {
      _bodyBytes.addAll(utf8.encode(object.toString()));
    }
  }

  Future<HttpClientResponse> close() async {
    final client = http.Client();
    try {
      final body = _bodyBytes.isNotEmpty ? _bodyBytes : null;
      final allHeaders = Map<String, String>.from(headers.toMap());

      late final http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(url, headers: allHeaders);
        case 'POST':
          response = await client.post(
            url,
            headers: allHeaders,
            body: body,
          );
        case 'PUT':
          response = await client.put(
            url,
            headers: allHeaders,
            body: body,
          );
        case 'DELETE':
          response = await client.delete(
            url,
            headers: allHeaders,
            body: body,
          );
        case 'PATCH':
          response = await client.patch(
            url,
            headers: allHeaders,
            body: body,
          );
        default:
          final request = http.Request(method, url);
          request.headers.addAll(allHeaders);
          if (body != null) {
            request.bodyBytes = body;
          }
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
      }

      return HttpClientResponse(
        statusCode: response.statusCode,
        bodyBytes: response.bodyBytes,
      );
    } finally {
      client.close();
    }
  }
}

class HttpClientResponse {
  HttpClientResponse({required this.statusCode, required this.bodyBytes});

  final int statusCode;
  final List<int> bodyBytes;

  Stream<T> transform<T>(StreamTransformer<List<int>, T> converter) {
    return Stream.fromIterable([bodyBytes]).transform(converter);
  }
}

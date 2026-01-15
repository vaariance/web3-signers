import 'dart:async';
import 'dart:convert';
import 'dart:io';

class MockRpcHandler extends HttpOverrides {
  final Map<String, dynamic> Function(String requestBody) handler;

  MockRpcHandler(this.handler);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(handler);
  }
}

class _MockHttpClient implements HttpClient {
  final Map<String, dynamic> Function(String requestBody) handler;

  _MockHttpClient(this.handler);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return _MockHttpClientRequest(handler);
  }

  @override
  void close({bool force = false}) {}

  // Implement other required members with stubs or throw UnimplementedError
  // The Verifier only uses postUrl.

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final Map<String, dynamic> Function(String requestBody) handler;
  final List<int> _body = [];

  _MockHttpClientRequest(this.handler);

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  void add(List<int> data) {
    _body.addAll(data);
  }

  @override
  Future<HttpClientResponse> close() async {
    final requestBody = utf8.decode(_body);
    final responseMap = handler(requestBody);
    final responseBody = jsonEncode(responseMap);
    return _MockHttpClientResponse(responseBody);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  final String body;

  _MockHttpClientResponse(this.body);

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return Stream.value(
      utf8.encode(body),
    ).map((e) => e as List<int>).transform(streamTransformer);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

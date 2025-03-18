import 'package:http/http.dart' as http;

class TimeoutHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Duration _timeout;

  TimeoutHttpClient({required Duration timeout}) : _timeout = timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Apply a timeout to every request
    return _inner.send(request).timeout(_timeout);
  }
}

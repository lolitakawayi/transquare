import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Creates an [http.Client] that routes through a proxy if configured.
///
/// When both [proxyHost] and [proxyPort] are provided (and [proxyHost] is
/// non-empty), all HTTP requests made with the returned client will be routed
/// through the specified proxy server. Otherwise a standard direct-connection
/// client is returned.
///
/// Example:
/// ```dart
/// final client = createHttpClient(proxyHost: '127.0.0.1', proxyPort: 7890);
/// // All requests from this client now go through 127.0.0.1:7890
/// ```
http.Client createHttpClient({
  String? proxyHost,
  int? proxyPort,
}) {
  if (proxyHost != null && proxyPort != null && proxyHost.isNotEmpty) {
    final httpClient = HttpClient();
    httpClient.findProxy = (url) {
      return 'PROXY $proxyHost:$proxyPort';
    };
    // Short idle timeout so the proxy connection does not hang indefinitely
    httpClient.idleTimeout = const Duration(seconds: 30);
    return IOClient(httpClient);
  }
  return http.Client();
}
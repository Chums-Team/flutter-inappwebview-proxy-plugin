import 'dart:io';
import 'package:http/io_client.dart';

// Get an http client to work through a proxy service
IOClient getProxyHttpClient({
  required final String addr, required final String port,
}) {
  final httpClient = HttpClient()
    ..findProxy = (uri) {
      return "PROXY $addr:$port";
    }
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  return IOClient(httpClient);
}

// HttpClient with local proxy
IOClient get defaultProxyHttpClient =>
    getProxyHttpClient(addr: '127.0.0.1', port: '3000');

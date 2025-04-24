import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_proxy/inappwebview_proxy.dart';
import 'package:flutter_inappwebview_proxy/inappwebview_proxy_utils.dart';

class InappWebViewProxyAndroid extends InappWebViewProxy {
  /// Registers this class as the default instance of [InappWebViewProxy].
  static void registerWith() {
    InappWebViewProxy.instance = InappWebViewProxyAndroid();
  }

  @override
  List<String> get resourceCustomSchemes => [];

  @override
  Uri? onLoadStart(final Uri? uri) => uri;

  @override
  URLRequest? onLoadUrl({final String? text}) {
    final url = (text ?? '');
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        return _paresUri(uri);
      }
    }
    return null;
  }

  @override
  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async => NavigationActionPolicy.ALLOW;

  @override
  Future<CustomSchemeResponse?> onLoadResourceWithCustomScheme(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async => null;

  @override
  Future<WebResourceResponse?> onShouldInterceptRequest(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async {

    if (httpClient == null || !useProxy(request.url.host, proxyDomains)) {
      return null;
    }

    try {
      final response = await httpClient!.get(
        request.url,
        headers: request.headers,
      );
      final contentType = responseContentType(response);
      final contentEncoding = responseContentEncoding(response);
      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location = response.headers['location'];
        if (location != null) {
          String content = '<script>location.href = "$location"</script>';
          final data = utf8.encode(content);
          return WebResourceResponse(
            data: data,
            contentType: 'text/html',
            headers: response.headers,
            statusCode: 200,
            reasonPhrase: response.reasonPhrase,
          );
        } else {
          return WebResourceResponse(
            contentType: contentType,
            contentEncoding: contentEncoding,
            data: response.bodyBytes,
            headers: response.headers,
            statusCode: 200,
            reasonPhrase: response.reasonPhrase,
          );
        }
      }
      return WebResourceResponse(
        contentType: contentType,
        contentEncoding: contentEncoding,
        data: response.bodyBytes,
        headers: response.headers,
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  URLRequest _paresUri(Uri url) {
    return URLRequest(url: WebUri.uri(formatUrl(url)));
  }

  Uri formatUrl(final Uri url) {
    if (!url.hasScheme && useProxy(url.host, proxyDomains)) {
      return url.replace(scheme: 'https');
    } else {
      if(!url.hasScheme) {
        return Uri.https(url.toString());
      } else {
        return url;
      }
    }
  }


}

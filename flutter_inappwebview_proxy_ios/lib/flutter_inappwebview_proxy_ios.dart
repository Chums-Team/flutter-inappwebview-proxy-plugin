import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';
import 'package:flutter_inappwebview_proxy/inappwebview_proxy.dart';
import 'package:flutter_inappwebview_proxy/inappwebview_proxy_utils.dart';

class InappWebViewProxyIos extends InappWebViewProxy {
  final Map<Uri, (URLRequest, String)> _customRequests = {};

  /// Registers this class as the default instance of [InappWebViewProxy].
  static void registerWith() {
    InappWebViewProxy.instance = InappWebViewProxyIos();
  }

  @override
  List<String> get resourceCustomSchemes => [customProxyScheme];

  @override
  Uri? onLoadStart(final Uri? uri) {
    final url = _unpackCustomUrl(uri);
    if (url?.toString().trim().isEmpty ?? true) {
      return null;
    } else {
      return url;
    }
  }

  @override
  URLRequest? onLoadUrl({final String? text}) {
    _customRequests.clear();
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
  ) async {
    final url = action.request.url;
    debugPrint('[shouldOverrideUrlLoading] url: $url, scheme: ${url?.scheme}');
    if (url != null) {
      if (url.scheme != customProxyScheme && useProxy(url.host, proxyDomains)) {
        final originUrl = url.toString();
        final chumsUrl = url.replace(scheme: customProxyScheme);
        debugPrint('[shouldOverrideUrlLoading] newUrl: $chumsUrl');
        final chumsRequest = URLRequest(
          url: WebUri.uri(chumsUrl),
          headers: action.request.headers,
          body: action.request.body,
          method: action.request.method,
        );
        _customRequests[chumsUrl] = (chumsRequest, originUrl);
        controller.loadUrl(urlRequest: chumsRequest);
        return NavigationActionPolicy.CANCEL;
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.ALLOW;
    }
  }

  @override
  Future<CustomSchemeResponse?> onLoadResourceWithCustomScheme(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async {
    final uri = request.url.uriValue;
    debugPrint('[onLoadResourceCustomScheme] uri: $uri');
    final scheme = uri.scheme;
    if (httpClient != null && scheme == customProxyScheme) {
      final chumsRequest = _customRequests[uri];
      late final Response response;
      late final Uri httpUri;
      if (chumsRequest != null) {
        httpUri = Uri.parse(chumsRequest.$2);
        debugPrint(
          '[onLoadResourceCustomScheme] custom request uri: $httpUri, headers: ${chumsRequest.$1.headers}',
        );
        try {
          response = await httpClient!.get(
            httpUri,
            headers: chumsRequest.$1.headers,
          );
        } catch (err) {
          debugPrint('[onLoadResourceCustomScheme] error: $err');
          return null;
        }
      } else {
        httpUri = uri.replace(scheme: 'https');
        debugPrint('[onLoadResourceCustomScheme] custom request uri: $httpUri');
        try {
          response = await httpClient!.get(httpUri);
        } catch (err) {
          debugPrint('[onLoadResourceCustomScheme] error: $err');
          return null;
        }
      }
      final contentType = responseContentType(response);
      final contentEncoding = responseContentEncoding(response);
      debugPrint('[onLoadResourceCustomScheme] custom request uri: $httpUri');
      debugPrint(
        '[onLoadResourceCustomScheme] proxyResponseContentType: $contentType',
      );
      debugPrint(
        '[onLoadResourceCustomScheme] proxyResponseContentEncoding: $contentEncoding',
      );
      debugPrint(
        '[onLoadResourceCustomScheme] proxyResponseBodySize: ${response.bodyBytes.length}',
      );
      debugPrint(
        '[onLoadResourceCustomScheme] proxyResponseStatus: ${response.statusCode}',
      );

      final location = response.headers['location'];
      if (response.statusCode >= 300 &&
          response.statusCode < 400 &&
          location != null) {
        controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri.uri(Uri.parse(location)),
            headers: chumsRequest?.$1.headers,
            body: chumsRequest?.$1.body,
            method: chumsRequest?.$1.method,
          ),
        );
        return null;
      }

      final customSchemeResponse = CustomSchemeResponse(
        data: response.bodyBytes,
        contentType: contentType,
        contentEncoding: contentEncoding,
      );

      return customSchemeResponse;
    } else {
      debugPrint('[onLoadResourceCustomScheme] unknown scheme: $scheme');
    }
    return null;
  }

  @override
  Future<WebResourceResponse?> onShouldInterceptRequest(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async => null;

  Uri? _unpackCustomUrl(final Uri? url) {
    if (url == null) {
      return url;
    }
    if (url.scheme == customProxyScheme) {
      return url.replace(scheme: 'http');
    } else {
      return url;
    }
  }

  URLRequest _paresUri(Uri url) {
    final customUrl = _buildCustomUrl(url);
    final request = URLRequest(url: WebUri.uri(customUrl));
    if (customUrl.scheme == customProxyScheme) {
      _customRequests[customUrl] = (request, url.toString());
    }
    return request;
  }

  _buildCustomUrl(final Uri url) {
    if (useProxy(url.host, proxyDomains)) {
      return url.replace(scheme: customProxyScheme);
    } else {
      if (!url.hasScheme) {
        return Uri.https(url.toString());
      } else {
        return url;
      }
    }
  }
}

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_proxy/inappwebview_proxy.dart';

class InappWebViewProxyWindows extends InappWebViewProxy {
  /// Registers this class as the default instance of [InappWebViewProxyPlatform].
  static void registerWith() {
    InappWebViewProxy.instance = InappWebViewProxyWindows();
  }

  @override
  List<String> get resourceCustomSchemes => throw UnimplementedError();

  @override
  Uri? onLoadStart(final Uri? uri) {
    throw UnimplementedError();
  }

  @override
  URLRequest? onLoadUrl({final String? text}) {
    throw UnimplementedError();
  }

  @override
  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction action,
      ) {
    throw UnimplementedError();
  }

  @override
  Future<CustomSchemeResponse?> onLoadResourceWithCustomScheme(
      InAppWebViewController controller,
      WebResourceRequest request,
      ) {
    throw UnimplementedError();
  }

  @override
  Future<WebResourceResponse?> onShouldInterceptRequest(
      InAppWebViewController controller,
      WebResourceRequest request,
      ) {
    throw UnimplementedError();
  }
}

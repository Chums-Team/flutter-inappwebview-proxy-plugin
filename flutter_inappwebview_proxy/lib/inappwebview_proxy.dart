import 'dart:collection';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/io_client.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'inappwebview_proxy_http_client_utils.dart';
import 'inappwebview_proxy_domains.dart';


abstract class InappWebViewProxy extends PlatformInterface {
  /// Constructs a InappWebViewProxy.
  InappWebViewProxy() : super(token: _token);

  static final Object _token = Object();

  static InappWebViewProxy _instance = _PlaceholderImplementation();

  static InappWebViewProxy get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InappWebViewProxy] when
  /// they register themselves.
  static set instance(InappWebViewProxy instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  String _customProxyScheme = 'proxy';

  String get customProxyScheme => _customProxyScheme;


  //Set custom scheme for using proxy in iOS
  void setCustomProxyScheme(final String scheme) => _customProxyScheme = scheme;

  IOClient? _httpClient;

  // A client that works through a proxy
  IOClient? get httpClient => _httpClient;

  // Set IOClient that works through a proxy
  void setProxyHttpClient(final IOClient client) {
    _httpClient?.close();
    _httpClient = client;
  }

  // Create a proxy http client by specifying the IP address and port of the proxy service
  void initProxyHttpClient({required final String addr, required final String port}) {
    setProxyHttpClient(getProxyHttpClient(addr: addr, port: port));
  }

  // Create an http client with default proxy settings (127.0.0.1:3000)
  void initDefaultProxyHttpClient() {
    setProxyHttpClient(defaultProxyHttpClient);
  }

  final List<String> _domains = [...defaultProxyDomains];

  // Domains for which the proxy service will be used
  UnmodifiableListView<String> get proxyDomains =>
      UnmodifiableListView(_domains);

  // Specify the domains for which the proxy service will be used
  setProxyDomains(final List<String> domains) {
    _domains.clear();
    _domains.addAll(domains);
  }

  // Initialize the class with the specified settings
  void init({
    final IOClient? httpClient,
    final List<String>? proxyDomains,
    final String? customProxyScheme,
  }) {
    if (httpClient != null) {
      setProxyHttpClient(httpClient);
    }
    if (proxyDomains != null) {
      setProxyDomains(proxyDomains);
    }
    if (customProxyScheme != null) {
      setCustomProxyScheme(customProxyScheme);
    }
  }

  dispose() {
    _httpClient?.close();
  }

  List<String> get resourceCustomSchemes;

  // Implementation of the onLoadStart method for InAppWebView
  Uri? onLoadStart(final Uri? uri);

  // It must be called every time the URL is changed from the outside.
  URLRequest? onLoadUrl({final String? text});

  // Implementation of the onShouldOverrideUrlLoading method for InAppWebView
  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  );

  // Implementation of the onLoadResourceWithCustomScheme method for InAppWebView
  Future<CustomSchemeResponse?> onLoadResourceWithCustomScheme(
    InAppWebViewController controller,
    WebResourceRequest request,
  );

  // Implementation of the onShouldInterceptRequest method for InAppWebView
  Future<WebResourceResponse?> onShouldInterceptRequest(
    InAppWebViewController controller,
    WebResourceRequest request,
  );
}

class _PlaceholderImplementation extends InappWebViewProxy {

  @override
  List<String> get resourceCustomSchemes => [];

  @override
  Future<CustomSchemeResponse?> onLoadResourceWithCustomScheme(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Uri? onLoadStart(Uri? uri) {
    throw UnimplementedError();
  }

  @override
  URLRequest? onLoadUrl({String? text}) {
    throw UnimplementedError();
  }

  @override
  Future<WebResourceResponse?> onShouldInterceptRequest(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) {
    throw UnimplementedError();
  }
}

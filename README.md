# flutter_inappwebview_proxy

[![License](https://img.shields.io/badge/License-Apache_2.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)

Flutter plugin for using a proxy in [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
_Currently, only Android and iOS platforms are supported._

### Usage example


<pre>
  ... 

  late final InappWebViewProxy _browserProxyService;  
  InAppWebViewController? _webViewController;

  void initState() {
    super.initState();
    _browserProxyService = InappWebViewProxy.instance
      ..initDefaultProxyHttpClient();
  }

  @override
  Widget build(BuildContext context) => InAppWebView(
    initialSettings: InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      useShouldInterceptRequest: true,

      // We can not intercept requests in IOS, so we use custom scheme to intercept requests
      resourceCustomSchemes: [if (Platform.isIOS) _browserProxyService.customProxyScheme],
      preferredContentMode: UserPreferredContentMode.MOBILE,
    ),
    onWebViewCreated: _onWebViewCreated,
    onLoadStart: _onLoadStart,

    // This is necessary to intercept requests from custom scheme.
    shouldOverrideUrlLoading: _browserProxyService.onShouldOverrideUrlLoading,

    // Intercept custom scheme requests in IOS
    onLoadResourceWithCustomScheme: _browserProxyService.onLoadResourceWithCustomScheme,

    // Intercept requests in Android
    shouldInterceptRequest: _browserProxyService.onShouldInterceptRequest,
  );

    _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    _loadUrl(_browserController.url.value);
  }

  _loadUrl(final String? text) async {
    final request = _browserProxyService.onLoadUrl(text: text);
    if(request != null) {
      _webViewController?.loadUrl(urlRequest: request);
    }
  }

  void _onLoadStart(_, Uri? uri) {
    final url = _browserProxyService.onLoadStart(uri);
    if(url != null) {
      // Update url
    }
  }

</pre>


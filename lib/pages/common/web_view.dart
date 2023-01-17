import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cobiz_client/tools/cobiz.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  final Function(String) call;
  WebViewPage(this.url, {this.call});

  @override
  State<StatefulWidget> createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _init();
  }

  _init() {
    eventBus.on('reloadweb', (arg) async {
      if (arg == true) {
        _controller.future.then((value) {
          value.reload();
        });
      }
    });
  }

  @override
  void dispose() {
    eventBus.off('reloadweb');
    super.dispose();
  }

  Widget body() {
    return Builder(builder: (BuildContext context) {
      return WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
        navigationDelegate: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) async {
          // print('Page finished loading: $url');
          if (widget.call != null) {
            await _controller.future.then((value) async {
              String title = await value.getTitle();
              if (title != null && title != '') {
                widget.call(title);
              }
            });
          }
        },
        onWebResourceError: (err) {
          // print(err);
        },
        gestureNavigationEnabled: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body());
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // Scaffold.of(context).showSnackBar(
        //   new SnackBar(content: Text(message.message)),
        // );
      },
    );
  }
}

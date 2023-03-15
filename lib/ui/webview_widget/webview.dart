import 'dart:convert';

import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/ui/webview_widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

///Chatwoot webview widget
/// {@category FlutterClientSdk}
class Webview extends StatefulWidget {
  late final String widgetUrl;
  late final String injectedJavaScript;
  final void Function()? closeWidget;

  Webview(
      {Key? key,
      required String websiteToken,
      required String baseUrl,
      ChatwootUser? user,
      String locale = "en",
      customAttributes,
      this.closeWidget})
      : super(key: key) {
    widgetUrl =
        "${baseUrl}/widget?website_token=${websiteToken}&locale=${locale}";

    injectedJavaScript = generateScripts(
        user: user, locale: locale, customAttributes: customAttributes);
  }

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  WebViewController? _controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String webviewUrl = widget.widgetUrl;
      final cwCookie = await StoreHelper.getCookie();
      if (cwCookie.isNotEmpty) {
        webviewUrl = "${webviewUrl}&cw_conversation=${cwCookie}";
      }
      setState(() {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) async {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                _goToUrl(request.url);
                return NavigationDecision.prevent;
              },
            ),
          )
          ..addJavaScriptChannel("ReactNativeWebView",
              onMessageReceived: (JavaScriptMessage jsMessage) {
            print("Chatwoot message received: ${jsMessage.message}");
            final message = getMessage(jsMessage.message);
            if (isJsonString(message)) {
              final parsedMessage = jsonDecode(message);
              final eventType = parsedMessage["event"];
              final type = parsedMessage["type"];
              if (eventType == 'loaded') {
                final authToken = parsedMessage["config"]["authToken"];
                StoreHelper.storeCookie(authToken);
                _controller?.runJavaScript(widget.injectedJavaScript);
              }
              if (type == 'close-widget') {
                widget.closeWidget?.call();
              }
            }
          })
          ..loadRequest(Uri.parse(webviewUrl));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : SizedBox();
  }

  _goToUrl(String url) {
    launchUrl(Uri.parse(url));
  }
}

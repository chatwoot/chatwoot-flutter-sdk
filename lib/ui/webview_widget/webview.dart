import 'dart:collection';
import 'dart:convert';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:chatwoot_sdk/ui/webview_widget/javascript_bridge.dart';
import 'package:chatwoot_sdk/ui/webview_widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// iOS asks about the initial URL as well as user navigation. Keep the widget's
// configured request embedded. Its query binds the inbox and stored conversation;
// web content must not replace those parameters before user configuration runs.
bool isWidgetNavigation(Uri target, Uri widgetUrl) =>
    target.scheme == widgetUrl.scheme &&
    target.host == widgetUrl.host &&
    target.port == widgetUrl.port &&
    target.path == widgetUrl.path &&
    target.query == widgetUrl.query;

///Chatwoot webview widget
/// {@category FlutterClientSdk}
class Webview extends StatefulWidget {
  /// Url for Chatwoot widget in webview
  late final String widgetUrl;

  /// Chatwoot user & locale initialisation script
  late final String injectedJavaScript;

  /// See [ChatwootWidget.closeWidget]
  final void Function()? closeWidget;

  /// See [ChatwootWidget.onLoadStarted]
  final void Function()? onLoadStarted;

  /// See [ChatwootWidget.onLoadProgress]
  final void Function(int)? onLoadProgress;

  /// See [ChatwootWidget.onLoadCompleted]
  final void Function()? onLoadCompleted;

  Webview({
    Key? key,
    required String websiteToken,
    required String baseUrl,
    ChatwootUser? user,
    String locale = "en",
    customAttributes,
    this.closeWidget,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted,
  }) : super(key: key) {
    widgetUrl =
        "${baseUrl}/widget?website_token=${websiteToken}&locale=${locale}";

    injectedJavaScript = generateScripts(
      user: user,
      locale: locale,
      customAttributes: customAttributes,
    );
  }

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  String? _webviewUrl;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String webviewUrl = widget.widgetUrl;

      final cwCookie = await StoreHelper.getCookie();
      if (!mounted) return;
      if (cwCookie.isNotEmpty) {
        webviewUrl = "$webviewUrl&cw_conversation=$cwCookie";
      }

      setState(() {
        _webviewUrl = webviewUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_webviewUrl == null) {
      return const SizedBox();
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_webviewUrl!)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        transparentBackground: true,
        allowFileAccess: true,
        allowContentAccess: true,
        useShouldOverrideUrlLoading: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: chatwootJavaScriptBridge,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
      onWebViewCreated: (controller) async {
        controller.addJavaScriptHandler(
          handlerName: "ReactNativeWebView",
          callback: (args) async {
            if (args.isEmpty) return;

            final message = getMessage(args.first);

            if (isJsonString(message)) {
              final parsedMessage = jsonDecode(message);

              final eventType = parsedMessage["event"];
              final type = parsedMessage["type"];

              if (eventType == 'loaded') {
                final authToken = parsedMessage["config"]["authToken"];
                StoreHelper.storeCookie(authToken);

                await controller.evaluateJavascript(
                  source: widget.injectedJavaScript,
                );
              }

              if (type == 'close-widget') {
                widget.closeWidget?.call();
              }
            }
          },
        );
      },
      onProgressChanged: (controller, progress) {
        widget.onLoadProgress?.call(progress);
      },
      onLoadStart: (controller, url) {
        widget.onLoadStarted?.call();
      },
      onLoadStop: (controller, url) async {
        widget.onLoadCompleted?.call();
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri != null) {
          if (isWidgetNavigation(uri, Uri.parse(_webviewUrl!))) {
            return NavigationActionPolicy.ALLOW;
          }
          _goToUrl(uri.toString());
        }
        return NavigationActionPolicy.CANCEL;
      },
      onReceivedError: (controller, request, error) {},
    );
  }

  _goToUrl(String url) {
    launchUrl(Uri.parse(url));
  }
}

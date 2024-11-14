import 'dart:convert';
import 'dart:io';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:chatwoot_sdk/ui/webview_widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';


///Chatwoot webview widget
/// {@category FlutterClientSdk}
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'dart:io';

class Webview extends StatefulWidget {
  /// URL for Chatwoot widget in webview
  late final String widgetUrl;

  /// Chatwoot user & locale initialization script
  late final String injectedJavaScript;

  /// See [ChatwootWidget.closeWidget]
  final void Function()? closeWidget;

  /// See [ChatwootWidget.onAttachFile]
  final Future<List<String>> Function()? onAttachFile;

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
    this.onAttachFile,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted,
  }) : super(key: key) {
    widgetUrl = "${baseUrl}/widget?website_token=${websiteToken}&locale=${locale}";

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
  late InAppWebViewController _controller;
  late String webviewUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      webviewUrl = widget.widgetUrl;
      final cwCookie = await StoreHelper.getCookie();
      if (cwCookie.isNotEmpty) {
        webviewUrl = "${webviewUrl}&cw_conversation=${cwCookie}";
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(webviewUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        useShouldOverrideUrlLoading: true,
        allowsInlineMediaPlayback: true,
        allowFileAccess: true,
        
      ),
      
      onWebViewCreated: (controller) {
        _controller = controller;

        // Inject JavaScript when the page is loaded
        _controller.addJavaScriptHandler(handlerName: "ReactNativeWebView", callback: (args) {
          final message = getMessage(args[0]);
          if (isJsonString(message)) {
            final parsedMessage = jsonDecode(message);
            final eventType = parsedMessage["event"];
            final type = parsedMessage["type"];
            if (eventType == 'loaded') {
              final authToken = parsedMessage["config"]["authToken"];
              StoreHelper.storeCookie(authToken);
              _controller.evaluateJavascript(source: widget.injectedJavaScript);
            }
            if (type == 'close-widget') {
              widget.closeWidget?.call();
            }
          }
        });
      },
      onLoadStart: (controller, url) {
        widget.onLoadStarted?.call();
      },
      onLoadStop: (controller, url) async {
        widget.onLoadCompleted?.call();
      },
      onProgressChanged: (controller, progress) {
        widget.onLoadProgress?.call(progress);
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("Console message: ${consoleMessage.message}");
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri != null && uri.toString() != webviewUrl) {
          _goToUrl(uri.toString());
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        print("Web resource error: $error");
      },
      
      // androidOnShowFileChooser: widget.onAttachFile != null
      //     ? (controller, filePathsCallback, fileChooserParams) async {
      //         final selectedFiles = await widget.onAttachFile!.call();
      //         filePathsCallback(selectedFiles.map((file) => Uri.file(file)).toList());
      //       }
      //     : null,
    );
  }

  void _goToUrl(String url) {
    // You may implement navigation behavior here if needed
    print("Navigating to $url");
  }

  @override
  void dispose() {
    super.dispose();
  }
}

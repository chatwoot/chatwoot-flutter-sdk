import 'package:chatwoot_client_sdk/ui/webview_widget/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestWebViewPlatform extends InAppWebViewPlatform {
  PlatformInAppWebViewWidgetCreationParams? creationParams;

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    creationParams = params;
    return _TestWebView(params);
  }
}

class _TestWebView extends PlatformInAppWebViewWidget {
  _TestWebView(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();

  @override
  void dispose() {}
}

void main() {
  testWidgets('keeps native origin protections for the remote widget', (
    tester,
  ) async {
    final previousPlatform = InAppWebViewPlatform.instance;
    final platform = _TestWebViewPlatform();
    InAppWebViewPlatform.instance = platform;
    addTearDown(() {
      if (previousPlatform != null) {
        InAppWebViewPlatform.instance = previousPlatform;
      }
    });
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: Webview(
          websiteToken: 'fixture',
          baseUrl: 'https://support.example.invalid',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final params = platform.creationParams!;
    final settings = params.initialSettings!;
    expect(params.initialUrlRequest!.url!.scheme, 'https');
    expect(settings.allowFileAccessFromFileURLs, isFalse);
    expect(settings.allowUniversalAccessFromFileURLs, isFalse);
    expect(settings.mixedContentMode, isNull);
    expect(settings.useShouldOverrideUrlLoading, isTrue);
  });
}

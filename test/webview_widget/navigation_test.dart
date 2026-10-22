import 'package:chatwoot_sdk/ui/webview_widget/webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final widgetUrl = Uri.parse(
    'https://support.example.invalid/widget?website_token=fixture&locale=en&cw_conversation=existing',
  );

  test('keeps the initial widget request and stored conversation embedded', () {
    expect(isWidgetNavigation(widgetUrl, widgetUrl), isTrue);
  });

  test('supports the initial widget request without a stored conversation', () {
    final firstVisit = Uri.parse(
      'https://support.example.invalid/widget?website_token=fixture&locale=en',
    );
    expect(isWidgetNavigation(firstVisit, firstVisit), isTrue);
  });

  test('keeps fragment navigation on the configured widget embedded', () {
    expect(
      isWidgetNavigation(widgetUrl.replace(fragment: 'messages'), widgetUrl),
      isTrue,
    );
  });

  test('recognizes the default HTTPS port', () {
    expect(
      isWidgetNavigation(
        Uri.parse(
          'https://support.example.invalid:443/widget?${widgetUrl.query}',
        ),
        widgetUrl,
      ),
      isTrue,
    );
  });

  test(
    'does not embed another origin, port, protocol or application route',
    () {
      for (final target in [
        'https://other.example.invalid/widget',
        'https://support.example.invalid:8443/widget',
        'http://support.example.invalid/widget',
        'https://support.example.invalid/app',
        'https://support.example.invalid/widget-untrusted',
        'mailto:fixture@example.invalid',
      ]) {
        expect(
          isWidgetNavigation(
            Uri.parse('$target?${widgetUrl.query}'),
            widgetUrl,
          ),
          isFalse,
          reason: target,
        );
      }
    },
  );

  test(
    'does not replace app-configured inbox, conversation or locale parameters',
    () {
      for (final query in [
        'website_token=another-inbox&locale=en&cw_conversation=existing',
        'locale=en&cw_conversation=existing',
        'website_token=fixture&locale=en&cw_conversation=another-conversation',
        'website_token=fixture&locale=fr&cw_conversation=existing',
        '${widgetUrl.query}&website_token=another-inbox',
        '${widgetUrl.query}&website_token=fixture',
        '${widgetUrl.query}&cw_conversation=another-conversation',
      ]) {
        expect(
          isWidgetNavigation(
            Uri.parse('https://support.example.invalid/widget?$query'),
            widgetUrl,
          ),
          isFalse,
          reason: query,
        );
      }
    },
  );
}

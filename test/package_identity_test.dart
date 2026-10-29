import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart' as official;
import 'package:chatwoot_client_sdk/chatwoot_sdk.dart' as compatibility;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('official and compatibility entry points expose the same SDK', () {
    final user = official.ChatwootUser(identifier: 'fixture-user');
    final widget = official.ChatwootWidget(
      websiteToken: 'fixture-inbox',
      baseUrl: 'https://example.invalid',
      user: user,
    );

    expect(widget.user, same(user));
    expect(
      compatibility.ChatwootUser(identifier: 'other-fixture'),
      isA<official.ChatwootUser>(),
    );
    expect(compatibility.ChatwootWidget, official.ChatwootWidget);
    expect(compatibility.ChatwootClient, official.ChatwootClient);
  });
}

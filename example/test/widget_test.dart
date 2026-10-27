import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('asks for configuration before loading a remote widget', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Chatwoot Example'), findsOneWidget);
    expect(find.textContaining('Set CHATWOOT_WEBSITE_TOKEN'), findsOneWidget);
    expect(find.byType(ChatwootWidget), findsNothing);
  });
}

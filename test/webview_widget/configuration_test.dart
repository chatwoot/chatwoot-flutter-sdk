import 'dart:convert';
import 'dart:io';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/ui/webview_widget/constants.dart';
import 'package:chatwoot_client_sdk/ui/webview_widget/utils.dart';
import 'package:flutter_test/flutter_test.dart';

const _page = r'''
const vm = require('node:vm');
const messages = [];
const page = {window: {postMessage: message => messages.push(message)}};
vm.runInNewContext(process.argv[1], page);
console.log(JSON.stringify({messages, injected: page.configurationInjected === true}));
''';

void main() {
  test(
    'customer configuration survives quotes, slashes and Unicode in JavaScript',
    () {
      const name = "O'Connor \\ \"Support\"\n日本語\u2028\u2029";
      final script = generateScripts(
        user: ChatwootUser(identifier: 'sdk-qa', name: name),
        locale: 'fr',
        customAttributes: {
          'note': name,
          'count': 0,
          'enabled': false,
          'empty': '',
        },
      );
      final result = Process.runSync('node', ['-e', _page, script]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      final output =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final messages = (output['messages'] as List)
          .map(
            (message) =>
                jsonDecode((message as String).substring(WOOT_PREFIX.length)),
          )
          .toList();
      expect(messages, hasLength(3));
      expect(messages[0]['user']['name'], name);
      expect(messages[0]['identifier'], 'sdk-qa');
      expect(messages[1]['locale'], 'fr');
      expect(messages[2]['customAttributes'], {
        'note': name,
        'count': 0,
        'enabled': false,
        'empty': '',
      });
    },
  );

  test('customer text remains data rather than executable JavaScript', () {
    const value = "'); globalThis.configurationInjected = true; //";
    final script = createWootPostMessage({'event': 'set-user', 'name': value});
    final result = Process.runSync('node', ['-e', _page, script]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(output['injected'], false);
    final message = (output['messages'] as List).single as String;
    expect(jsonDecode(message.substring(WOOT_PREFIX.length))['name'], value);
  });
}

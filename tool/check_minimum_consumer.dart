import 'dart:convert';
import 'dart:io';

// Run with the minimum supported Flutter SDK. Dependency dev tools are ignored
// by consumers, so resolve a real consumer rather than overriding SDK pins.
Future<void> main() async {
  final root = File.fromUri(Platform.script).parent.parent;
  final fixture = await Directory.systemTemp.createTemp('chatwoot-consumer-');
  try {
    File('${fixture.path}/pubspec.yaml').writeAsStringSync('''
name: chatwoot_minimum_consumer
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
  chatwoot_sdk:
    path: ${jsonEncode(root.path)}
  archive: ^4.5.2
dev_dependencies:
  flutter_test:
    sdk: flutter
  hive: 2.2.3
''');
    Directory('${fixture.path}/lib').createSync();
    File('${fixture.path}/lib/main.dart').writeAsStringSync('''
import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(ChatwootWidget(
  websiteToken: 'fixture-only',
  baseUrl: 'https://example.invalid',
  user: ChatwootUser(identifier: 'fixture', name: 'Fixture'),
));
''');
    for (final name in [
      'data/local/hive_upgrade_test.dart',
      'fixtures/legacy_hive_adapters.dart',
      'webview_widget/navigation_test.dart',
      'webview_widget/configuration_test.dart',
      'webview_widget/security_settings_test.dart',
    ]) {
      final target = File('${fixture.path}/test/$name');
      target.parent.createSync(recursive: true);
      File('${root.path}/test/$name').copySync(target.path);
    }
    for (final arguments in [
      ['pub', 'get'],
      ['analyze', 'lib'],
      ['test', '--concurrency=1', '--reporter=expanded'],
    ]) {
      stdout.writeln('flutter ${arguments.join(' ')}');
      final process = await Process.start(
        'flutter',
        arguments,
        workingDirectory: fixture.path,
        runInShell: Platform.isWindows,
      );
      final output = stdout.addStream(process.stdout);
      final errors = stderr.addStream(process.stderr);
      final result = await process.exitCode;
      await Future.wait([output, errors]);
      if (result != 0) {
        exitCode = result;
        return;
      }
    }
  } finally {
    await fixture.delete(recursive: true);
  }
}

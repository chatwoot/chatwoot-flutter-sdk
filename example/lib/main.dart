import 'dart:io';

import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _websiteToken = String.fromEnvironment('CHATWOOT_WEBSITE_TOKEN');
const _baseUrl = String.fromEnvironment(
  'CHATWOOT_BASE_URL',
  defaultValue: 'https://app.chatwoot.com',
);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatwoot SDK Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Chatwoot Example')),
        body: _websiteToken.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Set CHATWOOT_WEBSITE_TOKEN with --dart-define to open your widget. '
                    'For self-hosted Chatwoot, also set CHATWOOT_BASE_URL.',
                  ),
                ),
              )
            : ChatwootWidget(
                websiteToken: _websiteToken,
                baseUrl: _baseUrl,
                user: ChatwootUser(
                  identifier: 'test@test.com',
                  name: 'Tester test',
                  email: 'test@test.com',
                ),
                locale: 'en',
                closeWidget: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                onLoadStarted: () => debugPrint('loading widget'),
                onLoadProgress: (progress) =>
                    debugPrint('loading... $progress'),
                onLoadCompleted: () => debugPrint('widget loaded'),
              ),
      ),
    );
  }
}

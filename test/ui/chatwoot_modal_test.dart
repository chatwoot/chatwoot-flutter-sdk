//import 'dart:async';

import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/di/modules.dart';
import 'package:chatwoot_sdk/ui/chatwoot_chat_dialog.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

import '../data/chatwoot_repository_test.mocks.dart';
import '../utils/test_resources_util.dart';

void main() {
  final testInboxIdentifier = "testIdentifier";
  final testBaseUrl = "https://testbaseurl.com";
  late ProviderContainer mockProviderContainer;
  final mockService = MockChatwootClientService();

  final testUser = ChatwootUser(
      identifier: "identifier",
      identifierHash: "identifierHash",
      name: "name",
      email: "email",
      avatarUrl: "avatarUrl",
      customAttributes: {});
  final testClientInstanceKey = ChatwootClient.getClientInstanceKey(
      baseUrl: testBaseUrl,
      inboxIdentifier: testInboxIdentifier,
      userIdentifier: testUser.identifier);
  late final ChatwootContact mockContact;
  late final ChatwootConversation mockConversation;
  late final List<ChatwootMessage> mockMessages;
  final ChatwootL10n testL10n = ChatwootL10n();
  final mockWebSocketChannel = MockWebSocketChannel();
  final String testModalTitle = "ChatwootSupport";

  setUpAll(() async {
    mockContact = ChatwootContact.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "contact"));

    mockConversation = ChatwootConversation.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "conversation"));

    mockMessages = [
      ChatwootMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"))
    ];

    when(mockService.getContact())
        .thenAnswer((realInvocation) => Future.value(mockContact));
    when(mockService.getConversations())
        .thenAnswer((realInvocation) => Future.value([mockConversation]));
    when(mockService.getAllMessages())
        .thenAnswer((realInvocation) => Future.value(mockMessages));
    when(mockService.sendAction(any, any))
        .thenAnswer((realInvocation) => Future.microtask(() {}));

    when(mockService.connection).thenReturn(mockWebSocketChannel);

    mockProviderContainer = ProviderContainer();
    mockProviderContainer.updateOverrides([
      chatwootClientServiceProvider
          .overrideWithProvider((ref, param) => mockService)
    ]);
    ChatwootClient.providerContainerMap.update(
        testClientInstanceKey, (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
    ChatwootClient.providerContainerMap.update(
        "all", (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
  });

  testWidgets(
      'Given modal successfully instantiates when ChatwootChatModal is constructed, then modal should be correctly ',
      (WidgetTester tester) async {
    // WHEN
    await tester.pumpWidget(MaterialApp(
      home: ChatwootChatDialog(
        baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        title: testModalTitle,
        user: testUser,
        l10n: testL10n,
      ),
    ));

    // THEN
    expect(find.text(testModalTitle), findsOneWidget);
    expect(find.text(testL10n.offlineText), findsOneWidget);
  });
}

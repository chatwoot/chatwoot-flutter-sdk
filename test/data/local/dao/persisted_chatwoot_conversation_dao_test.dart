import 'dart:io';

import 'package:chatwoot_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Chatwoot Conversation Dao Tests", () {
    late PersistedChatwootConversationDao dao;
    late Box<String> mockClientInstanceKeyToConversationBox;
    late Box<ChatwootConversation> mockConversationBox;
    final testClientInstanceKey = "testKey";

    late final ChatwootConversation testConversation;

    setUpAll(() {
      return Future(() async {
        testConversation = ChatwootConversation.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "conversation"));

        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(ChatwootConversationAdapter())
          ..registerAdapter(ChatwootContactAdapter())
          ..registerAdapter(ChatwootMessageAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockConversationBox = await Hive.openBox(
            ChatwootConversationBoxNames.CONVERSATIONS.toString());
        mockClientInstanceKeyToConversationBox = await Hive.openBox(
            ChatwootConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS
                .toString());

        dao = PersistedChatwootConversationDao(mockConversationBox,
            mockClientInstanceKeyToConversationBox, testClientInstanceKey);
      });
    });

    test(
        'Given conversation is successfully deleted when deleteConversation is called, then getConversation should return null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.deleteConversation();

      //THEN
      expect(dao.getConversation(), null);
    });

    test(
        'Given conversation is successfully save when saveConversation is called, then getConversation should return saved conversation',
        () async {
      //WHEN
      await dao.saveConversation(testConversation);

      //THEN
      expect(dao.getConversation(), testConversation);
    });

    test(
        'Given conversation is successfully retrieved when getConversation is called, then retrieved conversation should not be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      final retrievedConversation = dao.getConversation();

      //THEN
      expect(retrievedConversation, testConversation);
    });

    test(
        'Given conversations are successfully cleared when clearAll is called, then retrieving a conversation should be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getConversation(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockConversationBox.clear();
          await mockClientInstanceKeyToConversationBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockConversationBox.close();
        await mockClientInstanceKeyToConversationBox.close();
      });
    });
  });
}

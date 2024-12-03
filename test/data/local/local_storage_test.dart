import 'dart:io';

import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/local/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_storage_test.mocks.dart';

@GenerateMocks([
  ChatwootConversationDao,
  ChatwootContactDao,
  ChatwootMessagesDao,
  PersistedChatwootConversationDao,
  PersistedChatwootContactDao,
  PersistedChatwootMessagesDao,
  ChatwootUserDao,
  PersistedChatwootUserDao
])
void main() {
  group("Local Storage Tests", () {
    final mockContactDao = MockChatwootContactDao();
    final mockConversationDao = MockChatwootConversationDao();
    final mockUserDao = MockChatwootUserDao();
    final mockMessagesDao = MockChatwootMessagesDao();

    late final LocalStorage localStorage;

    setUpAll(() {
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';

      Hive
        ..init(hiveTestPath)
        ..registerAdapter(ChatwootContactAdapter())
        ..registerAdapter(ChatwootConversationAdapter())
        ..registerAdapter(ChatwootMessageAdapter())
        ..registerAdapter(ChatwootUserAdapter())
        ..registerAdapter(ChatwootMessageAttachmentAdapter());

      localStorage = LocalStorage(
          userDao: mockUserDao,
          conversationDao: mockConversationDao,
          contactDao: mockContactDao,
          messagesDao: mockMessagesDao);
    });

    test(
        'Given persisted db is successfully opened when openDB is called, then all hive boxes should be open',
        () async {
      //WHEN
      await LocalStorage.openDB(onInitializeHive: () {});

      //THEN
      expect(true, Hive.isBoxOpen(ChatwootContactBoxNames.CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              ChatwootConversationBoxNames.CONVERSATIONS.toString()));
      expect(
          true,
          Hive.isBoxOpen(ChatwootConversationBoxNames
              .CLIENT_INSTANCE_TO_CONVERSATIONS
              .toString()));
      expect(
          true, Hive.isBoxOpen(ChatwootMessagesBoxNames.MESSAGES.toString()));
      expect(
          true,
          Hive.isBoxOpen(ChatwootMessagesBoxNames
              .MESSAGES_TO_CLIENT_INSTANCE_KEY
              .toString()));
      expect(true, Hive.isBoxOpen(ChatwootUserBoxNames.USERS.toString()));
      expect(true, Hive.isBoxOpen(ChatwootUserBoxNames.USERS.toString()));
    });

    test(
        'Given localStorage is successfully cleared when clear is called, then daos should be cleared',
        () async {
      //WHEN
      await localStorage.clear(clearChatwootUserStorage: true);

      //THEN
      verify(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verify(mockUserDao.deleteUser());
    });

    test(
        'Given localStorage is successfully cleared except user db when clear is called, then daos should be cleared except user db',
        () async {
      //WHEN
      await localStorage.clear(clearChatwootUserStorage: false);

      //THEN
      verifyNever(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verifyNever(mockUserDao.deleteUser());
    });

    test(
        'Given all data is successfully cleared when clearAll is called, then all data daos should be cleared',
        () async {
      //WHEN
      await localStorage.clearAll();

      //THEN
      verify(mockContactDao.clearAll());
      verify(mockConversationDao.clearAll());
      verify(mockMessagesDao.clearAll());
      verify(mockUserDao.clearAll());
    });

    test(
        'Given localStorage is successfully disposed when dispose is called, then all daos should be disposed',
        () {
      //WHEN
      localStorage.dispose();

      //THEN
      verify(mockContactDao.onDispose());
      verify(mockConversationDao.onDispose());
      verify(mockMessagesDao.onDispose());
      verify(mockUserDao.onDispose());
    });

    tearDownAll(() async {
      await Hive.close();
    });
  });
}

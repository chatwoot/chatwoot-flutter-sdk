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
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart' as legacy;
import 'package:hive_ce/hive.dart';

import '../../fixtures/legacy_hive_adapters.dart';

void main() {
  test(
    'Hive CE preserves a Hive 2 conversation, messages and user on upgrade',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sdk-hive-upgrade-',
      );
      addTearDown(() async {
        await legacy.Hive.close();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      const instance = 'fixture-client';
      final contact = ChatwootContact(
        id: 17,
        contactIdentifier: 'fixture-contact',
        pubsubToken: 'fixture-token',
        name: 'Fixture',
        email: 'fixture@example.invalid',
      );
      final sender = ChatwootEventMessageUser(id: 17, name: 'Fixture');
      final message = ChatwootMessage(
        id: 31,
        content: 'Persisted before upgrade',
        messageType: 0,
        contentType: 'text',
        contentAttributes: <String, dynamic>{'fixture': true},
        createdAt: '2026-01-01T00:00:00Z',
        conversationId: 23,
        attachments: <dynamic>[
          {'file_type': 'file', 'name': 'fixture.txt'},
        ],
        sender: sender,
      );
      final conversation = ChatwootConversation(
        id: 23,
        inboxId: 7,
        messages: [message],
        contact: contact,
      );
      final user = ChatwootUser(
        identifier: 'fixture-user',
        name: 'Fixture',
        email: 'fixture@example.invalid',
        customAttributes: <String, dynamic>{'plan': 'fixture'},
      );

      legacy.Hive
        ..init(directory.path)
        ..registerAdapter(LegacyChatwootContactAdapter())
        ..registerAdapter(LegacyChatwootConversationAdapter())
        ..registerAdapter(LegacyChatwootMessageAdapter())
        ..registerAdapter(LegacyChatwootUserAdapter())
        ..registerAdapter(LegacyChatwootEventMessageUserAdapter());
      final oldContacts = await legacy.Hive.openBox<ChatwootContact>(
        ChatwootContactBoxNames.CONTACTS.toString(),
      );
      await oldContacts.put(contact.contactIdentifier, contact);
      final oldContactMap = await legacy.Hive.openBox<String>(
        ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString(),
      );
      await oldContactMap.put(instance, contact.contactIdentifier!);
      final oldConversations = await legacy.Hive.openBox<ChatwootConversation>(
        ChatwootConversationBoxNames.CONVERSATIONS.toString(),
      );
      await oldConversations.put(conversation.id, conversation);
      final oldConversationMap = await legacy.Hive.openBox<String>(
        ChatwootConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS
            .toString(),
      );
      await oldConversationMap.put(instance, conversation.id.toString());
      final oldMessages = await legacy.Hive.openBox<ChatwootMessage>(
        ChatwootMessagesBoxNames.MESSAGES.toString(),
      );
      await oldMessages.put(message.id, message);
      final oldMessageMap = await legacy.Hive.openBox<String>(
        ChatwootMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString(),
      );
      await oldMessageMap.put(message.id, instance);
      final oldUsers = await legacy.Hive.openBox<ChatwootUser>(
        ChatwootUserBoxNames.USERS.toString(),
      );
      await oldUsers.put(user.identifier, user);
      final oldUserMap = await legacy.Hive.openBox<String>(
        ChatwootUserBoxNames.CLIENT_INSTANCE_TO_USER.toString(),
      );
      await oldUserMap.put(instance, user.identifier!);
      await legacy.Hive.close();

      // Exercise the SDK's real CE open path over files written by Hive 2.
      await LocalStorage.openDB(
        onInitializeHive: () {
          Hive
            ..init(directory.path)
            ..registerAdapter(ChatwootContactAdapter())
            ..registerAdapter(ChatwootConversationAdapter())
            ..registerAdapter(ChatwootMessageAdapter())
            ..registerAdapter(ChatwootUserAdapter())
            ..registerAdapter(ChatwootEventMessageUserAdapter());
        },
      );
      ChatwootConversation? readConversation() =>
          PersistedChatwootConversationDao(
            Hive.box(ChatwootConversationBoxNames.CONVERSATIONS.toString()),
            Hive.box(
              ChatwootConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS
                  .toString(),
            ),
            instance,
          ).getConversation();
      final contactDao = PersistedChatwootContactDao(
        Hive.box(ChatwootContactBoxNames.CONTACTS.toString()),
        Hive.box(
          ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString(),
        ),
        instance,
      );
      final messageDao = PersistedChatwootMessagesDao(
        Hive.box(ChatwootMessagesBoxNames.MESSAGES.toString()),
        Hive.box(
          ChatwootMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString(),
        ),
        instance,
      );
      final userDao = PersistedChatwootUserDao(
        Hive.box(ChatwootUserBoxNames.USERS.toString()),
        Hive.box(ChatwootUserBoxNames.CLIENT_INSTANCE_TO_USER.toString()),
        instance,
      );
      expect(contactDao.getContact(), contact);
      expect(readConversation(), conversation);
      expect(messageDao.getMessages(), [message]);
      expect(messageDao.getMessage(message.id)?.sender, sender);
      expect(userDao.getUser(), user);

      // A subsequent CE write/reopen must keep the original conversation intact.
      await userDao.saveUser(
        ChatwootUser(identifier: user.identifier, name: 'Updated'),
      );
      await Hive.close();
      await LocalStorage.openDB(
        onInitializeHive: () => Hive.init(directory.path),
      );
      expect(readConversation(), conversation);
      expect(
        PersistedChatwootUserDao(
          Hive.box(ChatwootUserBoxNames.USERS.toString()),
          Hive.box(ChatwootUserBoxNames.CLIENT_INSTANCE_TO_USER.toString()),
          instance,
        ).getUser()?.name,
        'Updated',
      );
    },
  );
}

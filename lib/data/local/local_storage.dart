import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entity/chatwoot_contact.dart';
import 'entity/chatwoot_message.dart';
import 'entity/chatwoot_user.dart';

const CHATWOOT_CONTACT_HIVE_TYPE_ID = 110;
const CHATWOOT_CONVERSATION_HIVE_TYPE_ID = 111;
const CHATWOOT_MESSAGE_HIVE_TYPE_ID = 112;
const CHATWOOT_USER_HIVE_TYPE_ID = 113;
const CHATWOOT_EVENT_USER_HIVE_TYPE_ID = 114;
const CHATWOOT_MESSAGE_ATTACHMENT_HIVE_TYPE_ID = 115;

class LocalStorage {
  ChatwootUserDao userDao;
  ChatwootConversationDao conversationDao;
  ChatwootContactDao contactDao;
  ChatwootMessagesDao messagesDao;

  LocalStorage({
    required this.userDao,
    required this.conversationDao,
    required this.contactDao,
    required this.messagesDao,
  });

  static Future<void> openDB({void Function()? onInitializeHive}) async {
    if (onInitializeHive == null) {
      await Hive.initFlutter("chatwoot");
      if (!Hive.isAdapterRegistered(CHATWOOT_CONTACT_HIVE_TYPE_ID)) {
        await Hive..registerAdapter(ChatwootContactAdapter());
      }
      if (!Hive.isAdapterRegistered(CHATWOOT_CONVERSATION_HIVE_TYPE_ID)) {
        await Hive..registerAdapter(ChatwootConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(CHATWOOT_MESSAGE_HIVE_TYPE_ID)) {
        Hive..registerAdapter(ChatwootMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(CHATWOOT_EVENT_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(ChatwootEventMessageUserAdapter());
      }
      if (!Hive.isAdapterRegistered(CHATWOOT_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(ChatwootUserAdapter());
      }
      if (!Hive.isAdapterRegistered(CHATWOOT_MESSAGE_ATTACHMENT_HIVE_TYPE_ID)) {
        Hive..registerAdapter(ChatwootMessageAttachmentAdapter());
      }
    } else {
      onInitializeHive();
    }

    await PersistedChatwootContactDao.openDB();
    await PersistedChatwootConversationDao.openDB();
    await PersistedChatwootMessagesDao.openDB();
    await PersistedChatwootUserDao.openDB();
  }

  Future<void> clear({bool clearChatwootUserStorage = true}) async {
    await conversationDao.deleteConversation();
    await messagesDao.clear();
    if (clearChatwootUserStorage) {
      await userDao.deleteUser();
      await contactDao.deleteContact();
    }
  }

  Future<void> clearAll() async {
    await conversationDao.clearAll();
    await contactDao.clearAll();
    await messagesDao.clearAll();
    await userDao.clearAll();
  }

  dispose() {
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}

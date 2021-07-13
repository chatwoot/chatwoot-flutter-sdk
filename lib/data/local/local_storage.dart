

import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entity/chatwoot_contact.dart';
import 'entity/chatwoot_conversation.dart';
import 'entity/chatwoot_message.dart';
import 'entity/chatwoot_user.dart';

class LocalStorage{
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

  static Future<void> openDB({void Function()? onInitializeHive}) async{

    if(onInitializeHive == null){
      await Hive.initFlutter();
      Hive
        ..registerAdapter(ChatwootContactAdapter())
        ..registerAdapter(ChatwootConversationAdapter())
        ..registerAdapter(ChatwootMessageAdapter())
        ..registerAdapter(ChatwootEventMessageUserAdapter())
        ..registerAdapter(ChatwootUserAdapter());
    }else{
      onInitializeHive();
    }

    await PersistedChatwootContactDao.openDB();
    await PersistedChatwootConversationDao.openDB();
    await PersistedChatwootMessagesDao.openDB();
    await PersistedChatwootUserDao.openDB();
  }

  Future<void> clear({bool clearChatwootUserStorage = true}) async{
    await conversationDao.deleteConversation();
    await contactDao.deleteContact();
    await messagesDao.clear();
    if(clearChatwootUserStorage){
      await userDao.deleteUser();
    }
  }

  Future<void> clearAll() async{
    await conversationDao.clearAll();
    await contactDao.clearAll();
    await messagesDao.clearAll();
    await userDao.clearAll();
  }

  dispose(){
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}
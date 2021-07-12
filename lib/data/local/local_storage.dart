

import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage{
  FlutterSecureStorage secureStorage;
  ChatwootUserDao userDao;
  ChatwootConversationDao conversationDao;
  ChatwootContactDao contactDao;
  ChatwootMessagesDao messagesDao;

  LocalStorage({
    required this.secureStorage,
    required this.userDao,
    required this.conversationDao,
    required this.contactDao,
    required this.messagesDao,
  });

  Future<void> openDB() async{
    if(contactDao is PersistedChatwootContactDao){
      await PersistedChatwootContactDao.openDB();
    }
    if(conversationDao is PersistedChatwootConversationDao){
      await PersistedChatwootConversationDao.openDB();
    }
    if(messagesDao is PersistedChatwootMessagesDao){
      await PersistedChatwootMessagesDao.openDB();
    }
    if(userDao is PersistedChatwootUserDao){
      await PersistedChatwootUserDao.openDB();
    }
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
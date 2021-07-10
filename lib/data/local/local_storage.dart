

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
    await userDao.openDB();
    await contactDao.openDB();
    await conversationDao.openDB();
    await messagesDao.openDB();
  }

  clear(){
    conversationDao.deleteConversation();
    contactDao.deleteContact();
    messagesDao.clear();
  }

  dispose(){
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}
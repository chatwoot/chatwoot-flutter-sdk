

import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:chatwoot_client_sdk/di/persistence_parameters.dart';
import 'package:chatwoot_client_sdk/di/repository_parameters.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';



final unauthenticatedDioProvider = Provider.family<Dio,ChatwootParameters>((ref,params) {
  return Dio(BaseOptions(baseUrl: params.baseUrl));
});

final chatwootClientApiInterceptorProvider = Provider.family<ChatwootClientApiInterceptor, ChatwootParameters>((ref,params) {
  final dio = ref.read(unauthenticatedDioProvider(params));
  final localStorage = ref.read(localStorageProvider(params));
  return ChatwootClientApiInterceptor(
      baseUrl: params.baseUrl,
      inboxIdentifier: params.inboxIdentifier,
      localStorage: localStorage,
      dio: dio
  );
});

final authenticatedDioProvider = Provider.family<Dio,ChatwootParameters>((ref,params) {
  final authenticatedDio = ref.read(unauthenticatedDioProvider(params));
  final interceptor = ref.read(chatwootClientApiInterceptorProvider(params));
  authenticatedDio.interceptors.add(interceptor);
  return authenticatedDio;
});

final chatwootClientServiceProvider = Provider.family<ChatwootClientService,ChatwootParameters>((ref,params) {
  final authenticatedDio = ref.read(authenticatedDioProvider(params));
  return ChatwootClientServiceImpl(
    params.baseUrl,
    dio: authenticatedDio
  );
});

final secureStoreProvider = Provider((ref)=>FlutterSecureStorage());

final clientInstanceToContactBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>("ClientInstanceToContact");
});

final clientInstanceToConversationBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>("ClientInstanceToConversation");
});

final messageToClientInstanceBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>("MessageToClientInstance");
});

final clientInstanceToUserBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>("ClientInstanceToUser");
});

final contactBoxProvider = Provider<Box<ChatwootContact>>((ref) {
  return ChatwootContact.getBox();
});

final conversationBoxProvider = Provider<Box<ChatwootConversation>>((ref) {
  return ChatwootConversation.getBox();
});

final messagesBoxProvider = Provider<Box<ChatwootMessage>>((ref) {
  return ChatwootMessage.getBox();
});

final userBoxProvider = Provider<Box<ChatwootUser>>((ref) {
  return ChatwootUser.getBox();
});

final chatwootContactDaoProvider = Provider.family<ChatwootContactDao, ChatwootParameters>(
        (ref, params){
          if(!params.isPersistenceEnabled){
            return NonPersistedChatwootContactDao();
          }

          final contactBox = ref.read(contactBoxProvider);
          final clientInstanceToContactBox = ref.read(clientInstanceToContactBoxProvider);
          return PersistedChatwootContactDao(
              contactBox,
              clientInstanceToContactBox,
              baseUrl: params.baseUrl,
              inboxIdentifier: params.inboxIdentifier,
              userIdentifier: params.userIdentifier
          );
        }
);

final chatwootConversationDaoProvider = Provider.family<ChatwootConversationDao, ChatwootParameters>((ref, params){
  if(!params.isPersistenceEnabled){
    return NonPersistedChatwootConversationDao();
  }
  final conversationBox = ref.read(conversationBoxProvider);
  final clientInstanceToConversationBox = ref.read(clientInstanceToConversationBoxProvider);
  return PersistedChatwootConversationDao(
      conversationBox,
      clientInstanceToConversationBox,
      baseUrl: params.baseUrl,
      inboxIdentifier: params.inboxIdentifier,
      userIdentifier: params.userIdentifier
  );
});

final chatwootMessagesDaoProvider = Provider.family<ChatwootMessagesDao, ChatwootParameters>((ref, params){
  if(!params.isPersistenceEnabled){
    return NonPersistedChatwootMessagesDao();
  }
  final messagesBox = ref.read(messagesBoxProvider);
  final messageToClientInstanceBox = ref.read(messageToClientInstanceBoxProvider);
  return PersistedChatwootMessagesDao(
      messagesBox,
      messageToClientInstanceBox,
      baseUrl: params.baseUrl,
      inboxIdentifier: params.inboxIdentifier,
      userIdentifier: params.userIdentifier
  );
});

final chatwootUserDaoProvider = Provider.family<ChatwootUserDao, ChatwootParameters>((ref, params){
  if(!params.isPersistenceEnabled){
    return NonPersistedChatwootUserDao();
  }
  final userBox = ref.read(userBoxProvider);
  final clientInstanceToUserBoxBox = ref.read(clientInstanceToUserBoxProvider);
  return PersistedChatwootUserDao(
      userBox,
      clientInstanceToUserBoxBox,
      baseUrl: params.baseUrl,
      inboxIdentifier: params.inboxIdentifier,
      userIdentifier: params.userIdentifier
  );
});

final localStorageProvider = Provider.family<LocalStorage, ChatwootParameters>((ref, params){

  final contactDao = ref.read(chatwootContactDaoProvider(params));
  final conversationDao = ref.read(chatwootConversationDaoProvider(params));
  final userDao = ref.read(chatwootUserDaoProvider(params));
  final messagesDao = ref.read(chatwootMessagesDaoProvider(params));
  final secureStore = ref.read(secureStoreProvider);

  return LocalStorage(
    contactDao: contactDao,
    conversationDao: conversationDao,
    userDao: userDao,
    messagesDao: messagesDao,
    secureStorage: secureStore
  );
});

final chatwootRepositoryProvider = Provider.family<ChatwootRepository, RepositoryParameters>((ref, repoParams){

  final localStorage = ref.read(localStorageProvider(repoParams.params));
  final clientService = ref.read(chatwootClientServiceProvider(repoParams.params));

  return ChatwootRepositoryImpl(
      clientService: clientService,
      localStorage: localStorage,
      streamCallbacks: repoParams.callbacks
  );
});
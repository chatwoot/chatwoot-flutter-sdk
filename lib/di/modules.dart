import 'package:chatwoot_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/local/local_storage.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_auth_service.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:chatwoot_sdk/chatwoot_parameters.dart';
import 'package:chatwoot_sdk/repository_parameters.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

///Provides an instance of [Dio]
final unauthenticatedDioProvider =
    Provider.family.autoDispose<Dio, ChatwootParameters>((ref, params) {
  return Dio(BaseOptions(baseUrl: params.baseUrl));
});

///Provides an instance of [ChatwootClientApiInterceptor]
final chatwootClientApiInterceptorProvider =
    Provider.family<ChatwootClientApiInterceptor, ChatwootParameters>(
        (ref, params) {
  final localStorage = ref.read(localStorageProvider(params));
  final authService = ref.read(chatwootClientAuthServiceProvider(params));
  return ChatwootClientApiInterceptor(
      params.inboxIdentifier, localStorage, authService);
});

///Provides an instance of Dio with interceptors set to authenticate all requests called with this dio instance
final authenticatedDioProvider =
    Provider.family.autoDispose<Dio, ChatwootParameters>((ref, params) {
  final authenticatedDio = Dio(BaseOptions(baseUrl: params.baseUrl));
  final interceptor = ref.read(chatwootClientApiInterceptorProvider(params));
  authenticatedDio.interceptors.add(interceptor);
  return authenticatedDio;
});

///Provides instance of chatwoot client auth service [ChatwootClientAuthService].
final chatwootClientAuthServiceProvider =
    Provider.family<ChatwootClientAuthService, ChatwootParameters>(
        (ref, params) {
  final unAuthenticatedDio = ref.read(unauthenticatedDioProvider(params));
  return ChatwootClientAuthServiceImpl(dio: unAuthenticatedDio);
});

///Provides instance of chatwoot client api service [ChatwootClientService].
final chatwootClientServiceProvider =
    Provider.family<ChatwootClientService, ChatwootParameters>((ref, params) {
      final authenticatedDio = ref.read(authenticatedDioProvider(params));
      final unauthenticatedDio = ref.read(unauthenticatedDioProvider(params));
  return ChatwootClientServiceImpl(params.baseUrl, dio: authenticatedDio, uDio: unauthenticatedDio);
});

///Provides hive box to store relations between chatwoot client instance and contact object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToContactBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
});

///Provides hive box to store relations between chatwoot client instance and conversation object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToConversationBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      ChatwootConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS.toString());
});

///Provides hive box to store relations between chatwoot client instance and messages,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final messageToClientInstanceBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      ChatwootMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString());
});

///Provides hive box to store relations between chatwoot client instance and user object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToUserBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      ChatwootUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
});

///Provides hive box for [ChatwootContact] object, which is used when persistence is enabled
final contactBoxProvider = Provider<Box<ChatwootContact>>((ref) {
  return Hive.box<ChatwootContact>(ChatwootContactBoxNames.CONTACTS.toString());
});

///Provides hive box for [ChatwootConversation] object, which is used when persistence is enabled
final conversationBoxProvider = Provider<Box<ChatwootConversation>>((ref) {
  return Hive.box<ChatwootConversation>(
      ChatwootConversationBoxNames.CONVERSATIONS.toString());
});

///Provides hive box for [ChatwootMessage] object, which is used when persistence is enabled
final messagesBoxProvider = Provider<Box<ChatwootMessage>>((ref) {
  return Hive.box<ChatwootMessage>(
      ChatwootMessagesBoxNames.MESSAGES.toString());
});

///Provides hive box for [ChatwootUser] object, which is used when persistence is enabled
final userBoxProvider = Provider<Box<ChatwootUser>>((ref) {
  return Hive.box<ChatwootUser>(ChatwootUserBoxNames.USERS.toString());
});

///Provides an instance of chatwoot user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// chatwoot client's contact
final chatwootContactDaoProvider =
    Provider.family<ChatwootContactDao, ChatwootParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedChatwootContactDao();
  }

  final contactBox = ref.read(contactBoxProvider);
  final clientInstanceToContactBox =
      ref.read(clientInstanceToContactBoxProvider);
  return PersistedChatwootContactDao(
      contactBox, clientInstanceToContactBox, params.clientInstanceKey);
});

///Provides an instance of chatwoot user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// chatwoot client's conversation
final chatwootConversationDaoProvider =
    Provider.family<ChatwootConversationDao, ChatwootParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedChatwootConversationDao();
  }
  final conversationBox = ref.read(conversationBoxProvider);
  final clientInstanceToConversationBox =
      ref.read(clientInstanceToConversationBoxProvider);
  return PersistedChatwootConversationDao(conversationBox,
      clientInstanceToConversationBox, params.clientInstanceKey);
});

///Provides an instance of chatwoot user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// chatwoot client's messages
final chatwootMessagesDaoProvider =
    Provider.family<ChatwootMessagesDao, ChatwootParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedChatwootMessagesDao();
  }
  final messagesBox = ref.read(messagesBoxProvider);
  final messageToClientInstanceBox =
      ref.read(messageToClientInstanceBoxProvider);
  return PersistedChatwootMessagesDao(
      messagesBox, messageToClientInstanceBox, params.clientInstanceKey);
});

///Provides an instance of chatwoot user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// user info
final chatwootUserDaoProvider =
    Provider.family<ChatwootUserDao, ChatwootParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedChatwootUserDao();
  }
  final userBox = ref.read(userBoxProvider);
  final clientInstanceToUserBoxBox = ref.read(clientInstanceToUserBoxProvider);
  return PersistedChatwootUserDao(
      userBox, clientInstanceToUserBoxBox, params.clientInstanceKey);
});

///Provides an instance of local storage
final localStorageProvider =
    Provider.family<LocalStorage, ChatwootParameters>((ref, params) {
  final contactDao = ref.read(chatwootContactDaoProvider(params));
  final conversationDao = ref.read(chatwootConversationDaoProvider(params));
  final userDao = ref.read(chatwootUserDaoProvider(params));
  final messagesDao = ref.read(chatwootMessagesDaoProvider(params));

  return LocalStorage(
      contactDao: contactDao,
      conversationDao: conversationDao,
      userDao: userDao,
      messagesDao: messagesDao);
});

///Provides an instance of chatwoot repository
final chatwootRepositoryProvider =
    Provider.family<ChatwootRepository, RepositoryParameters>(
        (ref, repoParams) {
  final localStorage = ref.read(localStorageProvider(repoParams.params));
  final clientService =
      ref.read(chatwootClientServiceProvider(repoParams.params));

  return ChatwootRepositoryImpl(
      clientService: clientService,
      localStorage: localStorage,
      streamCallbacks: repoParams.callbacks);
});

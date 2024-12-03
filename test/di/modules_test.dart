import 'dart:io';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:chatwoot_sdk/chatwoot_parameters.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_sdk/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group("Modules Test", () {
    late ProviderContainer providerContainer;

    final testChatwootParameters = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "https://testbaseUrl.com",
        inboxIdentifier: "testInboxIdentifier",
        clientInstanceKey: "testInstanceKey");

    setUpAll(() async {
      providerContainer = ProviderContainer();
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
      Hive
        ..init(hiveTestPath)
        ..registerAdapter(ChatwootContactAdapter())
        ..registerAdapter(ChatwootConversationAdapter())
        ..registerAdapter(ChatwootMessageAdapter())
        ..registerAdapter(ChatwootEventMessageUserAdapter())
        ..registerAdapter(ChatwootUserAdapter());

      await PersistedChatwootMessagesDao.openDB();
      await PersistedChatwootConversationDao.openDB();
      await PersistedChatwootContactDao.openDB();
      await PersistedChatwootUserDao.openDB();
    });

    test(
        'Given Dio instance is successfully provided when a read unauthenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(unauthenticatedDioProvider(testChatwootParameters));

      //THEN
      expect(result.options.baseUrl, equals(testChatwootParameters.baseUrl));
      final authInterceptorCount = result.interceptors.where((i)=>i is ChatwootClientApiInterceptor).length;
      expect(authInterceptorCount, equals(0));
    });

    test(
        'Given ChatwootClientAuthService instance is successfully provided when a read chatwootClientAuthServiceProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(chatwootClientAuthServiceProvider(testChatwootParameters));

      //THEN
      final authInterceptorCount = result.dio.interceptors.where((i)=>i is ChatwootClientApiInterceptor).length;
      expect(authInterceptorCount, equals(0));
    });

    test(
        'Given Dio instance is successfully provided when a read authenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(authenticatedDioProvider(testChatwootParameters));

      //THEN
      expect(result.options.baseUrl, equals(testChatwootParameters.baseUrl));
      final authInterceptorCount = result.interceptors.where((i)=>i is ChatwootClientApiInterceptor).length;
      expect(authInterceptorCount, equals(1));
    });

    test(
        'Given ChatwootContactDao instance is successfully provided when a read chatwootContactDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootContactDaoProvider(testChatwootParameters));

      //THEN
      expect(result is PersistedChatwootContactDao, equals(true));
    });

    test(
        'Given ChatwootContactDao instance is successfully provided when a read chatwootContactDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootContactDaoProvider(testChatwootParameters));

      //THEN
      expect(result is NonPersistedChatwootContactDao, equals(true));
    });

    test(
        'Given ChatwootConversationDao instance is successfully provided when a read chatwootConversationDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootConversationDaoProvider(testChatwootParameters));

      //THEN
      expect(result is PersistedChatwootConversationDao, equals(true));
    });

    test(
        'Given ChatwootConversationDao instance is successfully provided when a read chatwootConversationDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootConversationDaoProvider(testChatwootParameters));

      //THEN
      expect(result is NonPersistedChatwootConversationDao, equals(true));
    });

    test(
        'Given ChatwootMessagesDao instance is successfully provided when a read chatwootMessagesDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootMessagesDaoProvider(testChatwootParameters));

      //THEN
      expect(result is PersistedChatwootMessagesDao, equals(true));
    });

    test(
        'Given ChatwootMessagesDao instance is successfully provided when a read chatwootMessagesDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootMessagesDaoProvider(testChatwootParameters));

      //THEN
      expect(result is NonPersistedChatwootMessagesDao, equals(true));
    });

    test(
        'Given ChatwootUserDao instance is successfully provided when a read chatwootUserDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootUserDaoProvider(testChatwootParameters));

      //THEN
      expect(result is PersistedChatwootUserDao, equals(true));
    });

    test(
        'Given ChatwootUserDao instance is successfully provided when a read chatwootUserDaoProvider is called with persistence enabled, then return instance of PersistedChatwootContactDao',
        () async {
      //GIVEN
      final testChatwootParameters = ChatwootParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(chatwootUserDaoProvider(testChatwootParameters));

      //THEN
      expect(result is NonPersistedChatwootUserDao, equals(true));
    });

    tearDownAll(() async {
      Hive.close();
    });
  });
}

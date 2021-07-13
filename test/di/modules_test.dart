


import 'dart:io';

import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_conversation_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_client_sdk/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group("Client Api Interceptor Test", (){
    late ProviderContainer providerContainer;

    final testChatwootParameters = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "https://testbaseUrl.com",
        inboxIdentifier: "testInboxIdentifier",
        clientInstanceKey: "testInstanceKey"
    );

    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {}
    );

    setUpAll(() async{

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

    test('Given Dio instance is successfully provided when a read unauthenticatedDioProvider is called, then instance should be constructed properly', () async{


      //WHEN
      final result = providerContainer.read(unauthenticatedDioProvider(testChatwootParameters));

      //THEN
      expect(result.options.baseUrl, equals(testChatwootParameters.baseUrl));
      expect(result.interceptors.isEmpty, equals(true));
    });

    test('Given Dio instance is successfully provided when a read authenticatedDioProvider is called, then instance should be constructed properly', () async{


      //WHEN
      final result = providerContainer.read(authenticatedDioProvider(testChatwootParameters));

      //THEN
      expect(result.options.baseUrl, equals(testChatwootParameters.baseUrl));
      expect(result.interceptors.length, equals(1));
      expect(result.interceptors[0] is ChatwootClientApiInterceptor, equals(true));
    });

  });

}
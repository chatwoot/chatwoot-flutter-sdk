import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

import 'chatwoot_client_test.mocks.dart';
import 'data/chatwoot_repository_test.mocks.dart';
import 'utils/test_resources_util.dart';

@GenerateMocks([ChatwootRepository])
void main() {
  group("Chatwoot Client Test", () {
    late ChatwootClient client;
    final testInboxIdentifier = "testIdentifier";
    final testBaseUrl = "https://testbaseurl.com";
    late ProviderContainer mockProviderContainer;
    final mockLocalStorage = MockLocalStorage();
    final mockLocalStorageProvider = Provider.family((ref,params)=>mockLocalStorage);
    final mockRepository = MockChatwootRepository();
    final mockRepositoryProvider = Provider.family((ref,params)=>mockRepository);

    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});
    final testClientInstanceKey = ChatwootClient.getClientInstanceKey(
        baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        userIdentifier: testUser.identifier);

    setUp(() async {
      when(mockRepository.initialize(testUser))
          .thenAnswer((realInvocation) => Future.microtask(() {}));
      mockProviderContainer = ProviderContainer(
          overrides:[
            localStorageProvider
                .overrideWithProvider(mockLocalStorageProvider),
            chatwootRepositoryProvider
                .overrideWithProvider(mockRepositoryProvider)
          ]
      );
      ChatwootClient.providerContainerMap.update(
          testClientInstanceKey, (_) => mockProviderContainer,
          ifAbsent: () => mockProviderContainer);
      ChatwootClient.providerContainerMap.update(
          "all", (_) => mockProviderContainer,
          ifAbsent: () => mockProviderContainer);

      client = await ChatwootClient.create(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          user: testUser,
          enablePersistence: false);

      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    test(
        'Given all persisted data is successfully cleared when a clearAllData is called, then all local storage data should be cleared',
        () async {
      //GIVEN
      when(mockLocalStorage.clearAll())
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockLocalStorage.dispose())
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await ChatwootClient.clearAllData();

      //THEN
      verify(mockLocalStorage.clearAll());
    });

    test(
        'Given client persisted data is successfully cleared when a clearData is called, then clients local storage data should be cleared',
        () async {
      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_) => Future.microtask(() {}));
      when(mockLocalStorage.dispose())
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await ChatwootClient.clearData(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          userIdentifier: testUser.identifier);

      //THEN
      verify(mockLocalStorage.clear());
      verify(mockLocalStorage.dispose());
    });

    test(
        'Given client instance persisted data is successfully cleared when a clearClientData is called, then clients local storage data should be cleared',
        () async {
      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_) => Future.microtask(() {}));
      when(mockLocalStorage.dispose())
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await client.clearClientData();

      //THEN
      verify(mockLocalStorage.clear(clearChatwootUserStorage: false));
      verifyNever(mockLocalStorage.dispose());
    });

    test(
        'Given client instance is successfully disposed when a dispose is called, then repository should be disposed',
        () async {
      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_) => Future.microtask(() {}));
      when(mockLocalStorage.dispose())
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await client.dispose();

      //THEN
      verify(mockRepository.dispose());
      expect(ChatwootClient.providerContainerMap[testClientInstanceKey],
          equals(null));
    });

    test(
        'Given message sends successfully disposed when a sendMessage is called, then repository should be called',
        () async {
      //GIVEN
      when(mockRepository.sendMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await client.sendMessage(content: "test message", echoId: "id");

      //THEN
      verify(mockRepository.sendMessage(any));
    });

    test(
        'Given message sends successfully disposed when a sendMessage is called, then repository should be called',
        () async {
      //GIVEN
      when(mockRepository.sendMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await client.sendMessage(content: "test message", echoId: "id");

      //THEN
      verify(mockRepository.sendMessage(any));
    });

    test(
        'Given messages load successfully when a loadMessages is called, then repository should be called',
        () async {
      //GIVEN
      when(mockRepository.getMessages())
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockRepository.getPersistedMessages())
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      client.loadMessages();

      //THEN
      verify(mockRepository.getPersistedMessages());
      verify(mockRepository.getMessages());
    });

    test(
        'Given csat feedback is sent successfully when a sendCsatSurveyResults is called, then repository should be called',
            () async {
          //GIVEN
          final testConversationUuid = "conversation-uuid";
          final rating = 5;
          final feedback = "Excellent service";
          when(mockRepository.sendCsatFeedBack(any, any))
              .thenAnswer((_) => Future.microtask(() {}));

          //WHEN
          client.sendCsatSurveyResults(testConversationUuid, rating, feedback);

          //THEN
          verify(mockRepository.sendCsatFeedBack(testConversationUuid, SendCsatSurveyRequest(rating: rating, feedbackMessage: feedback)));
        });

    test(
        'Given action is sent successfully when a sendAction is called, then repository should be called',
            () async {
          //GIVEN
          when(mockRepository.sendAction(any))
              .thenAnswer((_) => Future.microtask(() {}));

          //WHEN
          client.sendAction(ChatwootActionType.update_presence);

          //THEN
          verify(mockRepository.sendAction(ChatwootActionType.update_presence));
        });

    test(
        'Given client is successfully initialized when a create is called without persistence enabled, then repository should be initialized',
        () async {
      //GIVEN

      //WHEN
      final result = await ChatwootClient.create(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          user: testUser,
          enablePersistence: false);

      //THEN
      verify(mockRepository.initialize(testUser));
      expect(result.baseUrl, equals(testBaseUrl));
      expect(result.inboxIdentifier, equals(testInboxIdentifier));
    });

    test(
        'Given client is successfully initialized when a create is called with persistence enabled, then repository should be initialized',
        () async {
      //GIVEN

      //WHEN
      final result = await ChatwootClient.create(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          user: testUser,
          enablePersistence: true);

      //THEN
      verify(mockRepository.initialize(testUser));
      expect(result.baseUrl, equals(testBaseUrl));
      expect(result.inboxIdentifier, equals(testInboxIdentifier));
    });
  });
}

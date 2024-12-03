import 'dart:async';
import 'dart:convert';

import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/local/local_storage.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/test_resources_util.dart';
import 'chatwoot_repository_test.mocks.dart';
import 'local/local_storage_test.mocks.dart';

@GenerateMocks(
    [LocalStorage, ChatwootClientService, ChatwootCallbacks, WebSocketChannel])
void main() {
  group("Chatwoot Repository Tests", () {
    late final ChatwootContact testContact;

    late final ChatwootConversation testConversation;
    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});
    late final ChatwootMessage testMessage;
    late final CsatSurveyFeedbackResponse testCsatFeedback;

    final mockLocalStorage = MockLocalStorage();
    final mockChatwootClientService = MockChatwootClientService();
    final mockChatwootCallbacks = MockChatwootCallbacks();
    final mockMessagesDao = MockChatwootMessagesDao();
    final mockContactDao = MockChatwootContactDao();
    final mockConversationDao = MockChatwootConversationDao();
    final mockUserDao = MockChatwootUserDao();
    StreamController mockWebSocketStream = StreamController.broadcast();
    final mockWebSocketChannel = MockWebSocketChannel();

    late final ChatwootRepository repo;

    setUpAll(() async {
      testContact = ChatwootContact.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "contact"));
      testConversation = ChatwootConversation.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "conversation"));
      testMessage = ChatwootMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"));
      testCsatFeedback = CsatSurveyFeedbackResponse.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "csat_feedback"));

      when(mockLocalStorage.messagesDao).thenReturn(mockMessagesDao);
      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockLocalStorage.userDao).thenReturn(mockUserDao);
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockChatwootClientService.connection)
          .thenReturn(mockWebSocketChannel);
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
      when(mockChatwootClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      repo = ChatwootRepositoryImpl(
          clientService: mockChatwootClientService,
          localStorage: mockLocalStorage,
          streamCallbacks: mockChatwootCallbacks);
    });

    setUp(() {
      reset(mockChatwootCallbacks);
      reset(mockContactDao);
      reset(mockConversationDao);
      reset(mockUserDao);
      reset(mockMessagesDao);
      when(mockContactDao.getContact()).thenReturn(testContact);
      mockWebSocketStream = StreamController.broadcast();
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
    });

    test(
        'Given messages are successfully fetched when getMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockChatwootClientService.getAllMessages())
          .thenAnswer((_) => Future.value(testMessages));
      when(mockChatwootCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveAllMessages(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockChatwootClientService.getAllMessages());
      verify(mockChatwootCallbacks.onMessagesRetrieved?.call(testMessages));
      verify(mockMessagesDao.saveAllMessages(testMessages));
    });

    test(
        'Given messages are fails to fetch when getMessages is called, then callback should be called with an error',
        () async {
      //GIVEN
      final testError = ChatwootClientException(
          "error", ChatwootClientExceptionType.GET_MESSAGES_FAILED);
      when(mockChatwootClientService.getAllMessages()).thenThrow(testError);
      when(mockChatwootCallbacks.onError).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockChatwootClientService.getAllMessages());
      verifyNever(mockChatwootCallbacks.onMessagesRetrieved);
      verify(mockChatwootCallbacks.onError?.call(testError));
      verifyNever(mockMessagesDao.saveAllMessages(any));
    });

    test(
        'Given persisted messages are successfully fetched when getPersitedMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockMessagesDao.getMessages()).thenReturn(testMessages);
      when(mockChatwootCallbacks.onPersistedMessagesRetrieved)
          .thenAnswer((_) => (_) {});

      //WHEN
      repo.getPersistedMessages();

      //THEN
      verifyNever(mockChatwootClientService.getAllMessages());
      verify(mockChatwootCallbacks.onPersistedMessagesRetrieved
          ?.call(testMessages));
    });

    test(
        'Given message is successfully sent when sendMessage is called, then callback should be called with sent message',
            () async {
          //GIVEN
          final messageRequest =
          ChatwootNewMessageRequest(content: "new message", echoId: "echoId");
          when(mockChatwootClientService.createMessage(any))
              .thenAnswer((_) => Future.value(testMessage));
          when(mockChatwootCallbacks.onMessageSent).thenAnswer((_) => (_, __) {});
          when(mockMessagesDao.saveMessage(any))
              .thenAnswer((_) => Future.microtask(() {}));

          //WHEN
          await repo.sendMessage(messageRequest);

          //THEN
          verify(mockChatwootClientService.createMessage(messageRequest));
          verify(mockChatwootCallbacks.onMessageSent
              ?.call(testMessage, messageRequest.echoId));
          verify(mockMessagesDao.saveMessage(testMessage));
        });

    test(
        'Given message fails to send when sendMessage is called, then callback should be called with an error',
            () async {
          //GIVEN
          final testError = ChatwootClientException(
              "error", ChatwootClientExceptionType.SEND_MESSAGE_FAILED);
          final messageRequest =
          ChatwootNewMessageRequest(content: "new message", echoId: "echoId");
          when(mockChatwootClientService.createMessage(any)).thenThrow(testError);
          when(mockChatwootCallbacks.onError).thenAnswer((_) => (_) {});

          //WHEN
          await repo.sendMessage(messageRequest);

          //THEN
          verify(mockChatwootClientService.createMessage(messageRequest));
          verify(mockChatwootCallbacks.onError?.call(testError));
          verifyNever(mockMessagesDao.saveMessage(any));
        });

    test(
        'Given csat survey is successfully recorded when sendCsatFeedBack is called, then callback should be called with feedback response',
            () async {
          //GIVEN
          final csatRequest = SendCsatSurveyRequest(rating: 5, feedbackMessage: "My issue was resolved promptly");
          when(mockChatwootClientService.sendCsatFeedBack(testConversation.uuid, csatRequest))
              .thenAnswer((_) => Future.value(testCsatFeedback));
          when(mockChatwootCallbacks.onCsatSurveyResponseRecorded).thenAnswer((_) => (_) {});

          //WHEN
          await repo.sendCsatFeedBack(testConversation.uuid!, csatRequest);

          //THEN
          verify(mockChatwootClientService.sendCsatFeedBack(testConversation.uuid, csatRequest));
          verify(mockChatwootCallbacks.onCsatSurveyResponseRecorded
              ?.call(testCsatFeedback));
        });

    test(
        'Given send csat survey fails to send when sendCsatFeedBack is called, then callback should be called with an error',
            () async {
          //GIVEN
          final testError = ChatwootClientException(
              "error", ChatwootClientExceptionType.SEND_CSAT_FEEDBACK);
          final csatRequest = SendCsatSurveyRequest(rating: 5, feedbackMessage: "My issue was resolved promptly");
          when(mockChatwootClientService.sendCsatFeedBack(testConversation.uuid, csatRequest)).thenThrow(testError);
          when(mockChatwootCallbacks.onError).thenAnswer((_) => (_) {});

          //WHEN
          await repo.sendCsatFeedBack(testConversation.uuid!, csatRequest);

          //THEN
          verify(mockChatwootClientService.sendCsatFeedBack(testConversation.uuid, csatRequest));
          verify(mockChatwootCallbacks.onError?.call(testError));
        });

    test(
        'Given repo is initialized with user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockChatwootClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockChatwootClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockChatwootClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(testUser);

      //THEN
      verify(mockChatwootClientService.getContact());
      verify(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given repo is initialized with null user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockChatwootClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockChatwootClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockChatwootClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(null);

      //THEN
      verifyNever(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given welcome event is received when listening for events, then callback welcome event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onWelcome).thenAnswer((_) => () {});
      final dynamic welcomeEvent = {"type": "welcome"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(welcomeEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onWelcome?.call());
    });

    test(
        'Given ping event is received when listening for events, then callback onPing event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onPing).thenAnswer((_) => () {});
      final dynamic pingEvent = {"type": "ping", "message": 12243849943};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(pingEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onPing?.call());
    });

    test(
        'Given confirm subscription event is received when listening for events, then callback onConfirmSubscription event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootClientService.sendAction(any, any))
          .thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConfirmedSubscription)
          .thenAnswer((_) => () {});
      final dynamic confirmSubscriptionEvent = {"type": "confirm_subscription"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(confirmSubscriptionEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onConfirmedSubscription?.call());
      verify(mockChatwootClientService.sendAction(
          testContact.pubsubToken, ChatwootActionType.update_presence));
    });

    test(
        'Given typing on event is received when listening for events, then callback onConversationStartedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConversationStartedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOnEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_on");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOnEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onConversationStartedTyping?.call());
    });

    test(
        'Given online presence update event is received when listening for events, then callback onConversationIsOnline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onConversationIsOnline?.call());
    });

    test(
        'Given conversation is offline when listening for events, then callback onConversationIsOffline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onError).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConversationIsOffline)
          .thenAnswer((_) => () {});
      when(mockChatwootCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 41));

      //THEN
      verify(mockChatwootCallbacks.onConversationIsOnline?.call());
      verify(mockChatwootCallbacks.onConversationIsOffline?.call());
    }, timeout: Timeout(Duration(seconds: 45)));

    test(
        'Given typing off event is received when listening for events, then callback onConversationStoppedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConversationStoppedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOffEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_off");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOffEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onConversationStoppedTyping?.call());
    });

    test(
        'Given conversation status changed event is received when listening for events, then callback onConversationResolved event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onConversationResolved)
          .thenAnswer((_) => (_) {});
      final dynamic resolvedEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_status_changed");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(resolvedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockChatwootCallbacks.onConversationResolved?.call(testConversation.uuid!));
    });

    test(
        'Given an updated message event is received when listening for events, then callback onMessageUpdated event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockChatwootCallbacks.onMessageUpdated).thenAnswer((_) => (_) {});
      final dynamic messageUpdatedEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_message_updated");

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageUpdatedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          ChatwootMessage.fromJson(messageUpdatedEvent["message"]["data"]);
      verify(mockChatwootCallbacks.onMessageUpdated?.call(message));
    });

    test(
        'Given new message event is sent when listening for events, then callback onMessageSent event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockChatwootCallbacks.onMessageDelivered)
          .thenAnswer((_) => (_, __) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      final dynamic messageSentEvent = {
        "type": "message",
        "message": {
          "event": "message.created",
          "data": {
            "id": 0,
            "content": "content",
            "echo_id": "echo_id",
            "message_type": 0,
            "content_type": "contentType",
            "content_attributes": "contentAttributes",
            "created_at": DateTime.now().toString(),
            "conversation_id": 0,
            "attachments": [],
          }
        }
      };

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageSentEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          ChatwootMessage.fromJson(messageSentEvent["message"]["data"]);
      verify(mockChatwootCallbacks.onMessageDelivered
          ?.call(message, messageSentEvent["message"]["echo_id"]));
    });

    test(
        'Given unknown event is received when listening for events, then no callback event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      final dynamic unknownEvent = {"type": "unknown"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(unknownEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verifyZeroInteractions(mockChatwootCallbacks);
      repo.dispose();
    });

    test(
        'Given action is successfully sent when sendAction is called, then client service sendAction should be triggered',
        () {
      //GIVEN
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockChatwootClientService.sendAction(any, any))
          .thenAnswer((realInvocation) => Future.microtask(() {}));

      //WHEN
      repo.sendAction(ChatwootActionType.update_presence);

      //THEN
      verify(mockChatwootClientService.sendAction(
          testContact.pubsubToken, ChatwootActionType.update_presence));
    });

    test(
        'Given repository is successfully disposed when dispose is called, then localStorage should be disposed',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.dispose();

      //THEN
      verify(mockLocalStorage.dispose());
    });

    test(
        'Given repository is successfully cleared when clear is called, then localStorage should be cleared',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.clear();

      //THEN
      verify(mockLocalStorage.clear());
    });

    tearDown(() async {
      await mockWebSocketStream.close();
    });

    tearDownAll(() {
      repo.dispose();
    });
  });
}

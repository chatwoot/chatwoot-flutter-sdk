import 'dart:convert';

import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/test_resources_util.dart';
import 'chatwoot_client_service_test.mocks.dart';

@GenerateMocks([Dio, WebSocketChannel, WebSocketSink])
void main() {
  group("Client Service Tests", () {
    late final ChatwootClientService clientService;
    final testBaseUrl = "https://test.com";
    final mockDio = MockDio();
    final unauthenticatedmockDio = MockDio();

    setUpAll(() {
      clientService = ChatwootClientServiceImpl(testBaseUrl,
          dio: mockDio, uDio: unauthenticatedmockDio);
    });

    _createSuccessResponse(body) {
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: ""));
    }

    _createErrorResponse({required int statusCode, body}) {
      return Response(
          data: body,
          statusCode: statusCode,
          requestOptions: RequestOptions(path: ""));
    }

    test(
        'Given message is successfully sent when createMessage is called, then return sent message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final request =
          ChatwootNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: anyNamed("data"))).thenAnswer((invocation) {
        assert(invocation.namedArguments[Symbol("data")] is FormData);
        final form = invocation.namedArguments[Symbol("data")] as FormData;
        final messageContent =
            form.fields.firstWhere((f) => f.key == "content").value;
        final echoId = form.fields.firstWhere((f) => f.key == "echo_id").value;
        expect(messageContent, request.content);
        expect(echoId, request.echoId);
        return Future.value(_createSuccessResponse(responseBody));
      });

      //WHEN
      final result = await clientService.createMessage(request);

      //THEN
      expect(result, ChatwootMessage.fromJson(responseBody));
    });

    test(
        'Given sending message returns with error response when createMessage is called, then throw error',
        () async {
      //GIVEN
      final request =
          ChatwootNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: anyNamed("data"))).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.createMessage(request);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given sending message fails when createMessage is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      final request =
          ChatwootNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: anyNamed("data"))).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.createMessage(request);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given messages are successfully fetched when getAllMessages is called, then return fetched messages',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "messages");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getAllMessages();

      //THEN
      final expected =
          responseBody.map((e) => ChatwootMessage.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch messages returns with error response when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getAllMessages();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given fetch messages fails when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getAllMessages();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given contact is successfully fetched when getContact is called, then return fetched contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getContact();

      //THEN
      expect(result, equals(ChatwootContact.fromJson(responseBody)));
    });

    test(
        'Given fetch contact returns with error response when getContact is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getContact();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given fetch contact fails when getContact is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getContact();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given conversations are successfully fetched when getConversations is called, then return fetched conversations',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "conversations");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getConversations();

      //THEN
      final expected =
          responseBody.map((e) => ChatwootConversation.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch conversations returns with error response when getConversations is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getConversations();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given fetch conversations fails when getConversations is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.getConversations();
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given contact is successfully updated when updateContact is called, then return updated contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateContact(update);

      //THEN
      expect(result, ChatwootContact.fromJson(responseBody));
    });

    test(
        'Given contact update returns with error response when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.updateContact(update);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given contact update fails when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.updateContact(update);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given message is successfully updated when updateMessage is called, then return updated message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateMessage(testMessageId, update);

      //THEN
      expect(result, ChatwootMessage.fromJson(responseBody));
    });

    test(
        'Given message update returns with error response when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given message update fails when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given csat survey is successfully sent when sendCsatFeedBack is called, then return feedback response',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "csat_feedback");
      final testConversationUuid = "conversation-uuid";
      final feedbackRequest =
          SendCsatSurveyRequest(rating: 1, feedbackMessage: "test message");
      final requestBody = {
        "message": {
          "submitted_values": {"csat_survey_response": feedbackRequest.toJson()}
        }
      };
      when(unauthenticatedmockDio.put(any, data: requestBody)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.sendCsatFeedBack(
          testConversationUuid, feedbackRequest);

      //THEN
      expect(result, CsatSurveyFeedbackResponse.fromJson(responseBody));
    });

    test(
        'Given send csat survey returns with error response when sendCsatFeedBack is called, then throw error',
        () async {
      //GIVEN
      final testConversationUuid = "conversation-uuid";
      final feedbackRequest =
          SendCsatSurveyRequest(rating: 1, feedbackMessage: "test message");
      final requestBody = {
        "message": {
          "submitted_values": {"csat_survey_response": feedbackRequest.toJson()}
        }
      };
      when(unauthenticatedmockDio.put(any, data: requestBody)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 500, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.sendCsatFeedBack(
            testConversationUuid, feedbackRequest);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      verify(unauthenticatedmockDio.put(argThat(contains(testConversationUuid)),
          data: requestBody));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.SEND_CSAT_FEEDBACK));
    });

    test(
        'Given send csat feedback fails when sendCsatFeedBack is called, then throw error',
        () async {
      //GIVEN
      final testConversationUuid = "conversation-uuid";
      final feedbackRequest =
          SendCsatSurveyRequest(rating: 1, feedbackMessage: "test message");
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      final requestBody = {
        "message": {
          "submitted_values": {"csat_survey_response": feedbackRequest.toJson()}
        }
      };
      when(unauthenticatedmockDio.put(any, data: requestBody))
          .thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try {
        await clientService.sendCsatFeedBack(
            testConversationUuid, feedbackRequest);
      } on ChatwootClientException catch (e) {
        chatwootClientException = e;
      }

      //THEN
      verify(unauthenticatedmockDio.put(argThat(contains(testConversationUuid)),
          data: requestBody));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type,
          equals(ChatwootClientExceptionType.SEND_CSAT_FEEDBACK));
    });

    test(
        'Given websocket connection is successful when startWebSocketConnection is called, then subscribe for events',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      final WebSocketChannel Function(Uri) startConnection = (Uri uri) {
        return mockWebSocketChannel;
      };
      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));

      //WHEN
      clientService.startWebSocketConnection(testPubsubtoken,
          onStartConnection: startConnection);

      //THEN
      final subscriptionPayload = jsonEncode({
        "command": "subscribe",
        "identifier": jsonEncode(
            {"channel": "RoomChannel", "pubsub_token": testPubsubtoken})
      });
      verify(mockWebSocketSink.add(subscriptionPayload));
      mockWebSocketSink.close();
    });

    test(
        'Given action is sent successfully when sendAction is called, then websocket sink should be triggered',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));
      clientService.connection = mockWebSocketChannel;

      //WHEN
      clientService.sendAction(
          testPubsubtoken, ChatwootActionType.update_presence);

      //THEN
      verify(mockWebSocketSink.add(any));
    });
  });
}

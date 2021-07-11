
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chatwoot_client_service_test.mocks.dart';

@GenerateMocks([
  Dio
])
void main() {
  group("Non Persisted Chatwoot Contact Dao Test", (){
    late final ChatwootClientService clientService ;
    final testBaseUrl = "https://test.com";
    final mockDio = MockDio();

    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {}
    );

    setUpAll((){
      clientService = ChatwootClientServiceImpl(testBaseUrl, dio: mockDio);
    });

    _createSuccessResponse(body){
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: "")
      );
    }

    _createErrorResponse({required int statusCode, body}){
      return Response(
        data: body,
        statusCode: statusCode,
        requestOptions: RequestOptions(path: "")
      );
    }

    test('Given contact is successfully created when createNewContact is called, then return created contact', () async{

      //GIVEN
      final responseBody = {
        "id": 0,
        "source_id": "contactIdentifier",
        "pubsub_token": "pubsubToken",
        "name": "name",
        "email": "email"
      };
      when(mockDio.post(any, data: testUser.toJson())).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createNewContact(testUser);

      //THEN
      expect(result, ChatwootContact.fromJson(responseBody));

    });

    test('Given contact creation returns with error response when createNewContact is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.post(any, data: testUser.toJson())
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createNewContact(testUser);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.CREATE_CONTACT_FAILED));

    });

    test('Given contact creation fails when createNewContact is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.post(any, data: testUser.toJson())
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createNewContact(testUser);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.CREATE_CONTACT_FAILED));

    });

    test('Given conversation is successfully created when createNewConversation is called, then return created conversation', () async{

      //GIVEN
      final responseBody = {
        "id": 0,
        "inbox_id": "",
        "messages": "",
        "contact": ""
      };
      when(mockDio.post(any)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createNewConversation();

      //THEN
      expect(result, ChatwootConversation.fromJson(responseBody));

    });

    test('Given conversation creation returns with error response when createNewConversation is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.post(any)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createNewConversation();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.CREATE_CONVERSATION_FAILED));

    });

    test('Given conversation creation fails when createNewConversation is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.post(any)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createNewConversation();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.CREATE_CONVERSATION_FAILED));

    });

    test('Given message is successfully sent when createMessage is called, then return sent message', () async{

      //GIVEN
      final responseBody = {
        "id": "id",
        "content": "content",
        "message_type": "1",
        "content_type": "contentType",
        "content_attributes": "contentAttributes",
        "created_at": DateTime.now().toString(),
        "conversation_id": "conversationId",
        "attachments": [],
        "sender": "sender"
      };
      final request = ChatwootNewMessageRequest(content: "test message",echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createMessage(request);

      //THEN
      expect(result, ChatwootMessage.fromJson(responseBody));

    });

    test('Given sending message returns with error response when createMessage is called, then throw error', () async{

      //GIVEN
      final request = ChatwootNewMessageRequest(content: "test message",echoId: "id");
      when(
          mockDio.post(any,  data: request.toJson())
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createMessage(request);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.SEND_MESSAGE_FAILED));

    });

    test('Given sending message fails when createMessage is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      final request = ChatwootNewMessageRequest(content: "test message",echoId: "id");
      when(
          mockDio.post(any,  data: request.toJson())
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.createMessage(request);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.SEND_MESSAGE_FAILED));

    });

    test('Given messages are successfully fetched when getAllMessages is called, then return fetched messages', () async{

      //GIVEN
      final dynamic responseBody = [
        {
          "id": "id",
          "content": "content",
          "message_type": "1",
          "content_type": "contentType",
          "content_attributes": "contentAttributes",
          "created_at": DateTime.now().toString(),
          "conversation_id": "conversationId",
          "attachments": [],
          "sender": "sender"
        }
      ];
      when(mockDio.get(any)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getAllMessages();

      //THEN
      final expected =responseBody.map((e) => ChatwootMessage.fromJson(e)).toList();
      expect(result, equals(expected));

    });

    test('Given fetch messages returns with error response when getAllMessages is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.get(any)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getAllMessages();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_MESSAGES_FAILED));

    });

    test('Given fetch messages fails when getAllMessages is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.get(any)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getAllMessages();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_MESSAGES_FAILED));

    });

    test('Given contact is successfully fetched when getContact is called, then return fetched contact', () async{

      //GIVEN
      final responseBody = {
        "id": 0,
        "source_id": "contactIdentifier",
        "pubsub_token": "pubsubToken",
        "name": "name",
        "email": "email"
      };
      when(mockDio.get(any)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getContact();

      //THEN
      expect(result, equals(ChatwootContact.fromJson(responseBody)));

    });

    test('Given fetch contact returns with error response when getContact is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.get(any)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getContact();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_CONTACT_FAILED));

    });

    test('Given fetch contact fails when getContact is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.get(any)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getContact();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_CONTACT_FAILED));

    });

    test('Given conversations are successfully fetched when getConversations is called, then return fetched conversations', () async{

      //GIVEN
      final dynamic responseBody = [
        {
          "id": 0,
          "inbox_id": "",
          "messages": "",
          "contact": ""
        }
      ];
      when(mockDio.get(any)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getConversations();

      //THEN
      final expected =responseBody.map((e) => ChatwootConversation.fromJson(e)).toList();
      expect(result, equals(expected));

    });

    test('Given fetch conversations returns with error response when getConversations is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.get(any)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getConversations();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_CONVERSATION_FAILED));

    });

    test('Given fetch conversations fails when getConversations is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.get(any)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.getConversations();
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.GET_CONVERSATION_FAILED));

    });


    test('Given contact is successfully updated when updateContact is called, then return updated contact', () async{

      //GIVEN
      final responseBody = {
        "id": 0,
        "source_id": "contactIdentifier",
        "pubsub_token": "pubsubToken",
        "name": "name",
        "email": "email"
      };
      final update = {
        "name":"Updated name"
      };
      when(mockDio.patch(any, data: update)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateContact(update);

      //THEN
      expect(result, ChatwootContact.fromJson(responseBody));

    });

    test('Given contact update returns with error response when updateContact is called, then throw error', () async{

      //GIVEN
      final update = {
        "name":"Updated name"
      };
      when(
          mockDio.patch(any, data: update)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.updateContact(update);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.UPDATE_CONTACT_FAILED));

    });

    test('Given contact update fails when updateContact is called, then throw error', () async{

      //GIVEN
      final update = {
        "name":"Updated name"
      };
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.patch(any, data: update)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.updateContact(update);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.UPDATE_CONTACT_FAILED));

    });


    test('Given message is successfully updated when updateMessage is called, then return updated message', () async{

      //GIVEN
      final responseBody = {
        "id": "id",
        "content": "content",
        "message_type": "1",
        "content_type": "contentType",
        "content_attributes": "contentAttributes",
        "created_at": DateTime.now().toString(),
        "conversation_id": "conversationId",
        "attachments": [],
        "sender": "sender"
      };
      final testMessageId = "id";
      final update = {
        "content":"Updated content"
      };
      when(mockDio.patch(any, data: update)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateMessage(testMessageId,update);

      //THEN
      expect(result, ChatwootMessage.fromJson(responseBody));

    });

    test('Given message update returns with error response when updateMessage is called, then throw error', () async{

      //GIVEN
      final testMessageId = "id";
      final update = {
        "content":"Updated content"
      };
      when(
          mockDio.patch(any, data: update)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.updateMessage(testMessageId,update);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)),data: update));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED));

    });

    test('Given message update fails when updateMessage is called, then throw error', () async{

      //GIVEN
      final testMessageId = "id";
      final update = {
        "content":"Updated content"
      };
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.patch(any, data: update)
      ).thenThrow(testError);

      //WHEN
      ChatwootClientException? chatwootClientException;
      try{
        await clientService.updateMessage(testMessageId, update);
      }on ChatwootClientException catch (e){
        chatwootClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)),data: update));
      expect(chatwootClientException, isNotNull);
      expect(chatwootClientException!.type, equals(ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED));

    });

  });

}
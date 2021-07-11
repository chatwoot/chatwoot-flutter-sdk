
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_auth_service.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../chatwoot_repository_test.mocks.dart';
import '../local/local_storage_test.mocks.dart';
import 'chatwoot_client_api_interceptor_test.mocks.dart';
import 'chatwoot_client_service_test.mocks.dart';

@GenerateMocks([
  ResponseInterceptorHandler,
  RequestInterceptorHandler,
  ChatwootClientAuthService
])
void main() {
  group("Client Api Interceptor Test", (){
    late final ChatwootClientApiInterceptor interceptor ;
    final testInboxIdentifier = "testIdentifier";
    final mockAuthService = MockChatwootClientAuthService();
    final mockLocalStorage = MockLocalStorage();
    final mockContactDao = MockChatwootContactDao();
    final mockUserDao = MockChatwootUserDao();
    final mockDio = MockDio();
    final mockConversationDao = MockChatwootConversationDao();
    final mockResponseHandler = MockResponseInterceptorHandler();
    final mockRequestHandler = MockRequestInterceptorHandler();
    final testContact = ChatwootContact(
        id: 0,
        contactIdentifier: "contactIdentifier",
        pubsubToken: "pubsubToken",
        name: "name",
        email: "email"
    );

    final testConversation = ChatwootConversation(
        id: 0,
        inboxId: "",
        messages: "",
        contact: ""
    );

    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {}
    );

    setUpAll((){
      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockLocalStorage.userDao).thenReturn(mockUserDao);
      when(mockAuthService.dio).thenReturn(mockDio);
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      interceptor = ChatwootClientApiInterceptor(
          testInboxIdentifier,
          mockLocalStorage,
          mockAuthService
      );
    });

    _createSuccessResponse(body){
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: "",headers: new Map())
      );
    }

    _createErrorResponse({required int statusCode, body}){
      return Response(
        data: body,
        statusCode: statusCode,
        requestOptions: RequestOptions(path: "",headers: new Map())
      );
    }

    test('Given api response is 401 unauthorized when a response is returned, then recreate contact and resubmit request', () async{

      //GIVEN
      final testResponse = _createErrorResponse(statusCode: 401);

      when(mockDio.fetch(any)).thenAnswer((_)=>Future.value(_createSuccessResponse({})));
      when(mockUserDao.getUser()).thenReturn(testUser);
      when(mockAuthService.createNewContact(any, any)).thenAnswer((_) => Future.value(testContact));
      when(mockAuthService.createNewConversation(any, any)).thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onResponse(testResponse,mockResponseHandler);

      //THEN
      verify(mockAuthService.createNewContact(testInboxIdentifier, testUser));
      verify(mockAuthService.createNewConversation(testInboxIdentifier, testContact.contactIdentifier));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockResponseHandler.next(any));

    });

    test('Given api response is not 401 unauthorized when a response is returned, then forward response through handler', () async{

      //GIVEN
      final testResponse = _createErrorResponse(statusCode: 400);


      //WHEN
      await interceptor.onResponse(testResponse,mockResponseHandler);

      //THEN
      verify(mockResponseHandler.next(any));
      verifyNever(mockAuthService.createNewContact(any, any));
      verifyNever(mockAuthService.createNewConversation(any, any));
      verifyNever(mockContactDao.saveContact(any));
      verifyNever(mockConversationDao.saveConversation(any));

    });

    test('Given api response is successful when a response is returned, then forward response through handler', () async{

      //GIVEN
      final testResponse = _createSuccessResponse({});


      //WHEN
      await interceptor.onResponse(testResponse,mockResponseHandler);

      //THEN
      verify(mockResponseHandler.next(any));
      verifyNever(mockAuthService.createNewContact(any, any));
      verifyNever(mockAuthService.createNewConversation(any, any));
      verifyNever(mockContactDao.saveContact(any));
      verifyNever(mockConversationDao.saveConversation(any));

    });

  });

}
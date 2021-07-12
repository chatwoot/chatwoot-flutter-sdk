
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../chatwoot_repository_test.mocks.dart';
import '../local/local_storage_test.mocks.dart';
import 'chatwoot_client_api_interceptor_test.mocks.dart';
import 'chatwoot_client_service_test.mocks.dart';

class _HasAuthorizationHeader extends Matcher {
  final String _authHeaderValue;
  const _HasAuthorizationHeader(this._authHeaderValue);

  @override
  bool matches(item, Map matchState) => (item as RequestOptions).headers["AUTHORIZATION"] == _authHeaderValue;

  @override
  Description describe(Description description) =>
      description.addDescriptionOf(_authHeaderValue);
}

class _HasPath extends Matcher {
  final String _pathValue;
  const _HasPath(this._pathValue);

  @override
  bool matches(item, Map matchState) => (item as RequestOptions).path == _pathValue;

  @override
  Description describe(Description description) =>
      description.addDescriptionOf(_pathValue);
}

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

    test('Given persisted contact is null when a request is made, then recreate contact and submit request', () async{

      //GIVEN
      final testRequest = RequestOptions(path: "/");

      when(mockContactDao.getContact()).thenReturn(null);
      when(mockConversationDao.getConversation()).thenReturn(null);
      when(mockUserDao.getUser()).thenReturn(testUser);
      when(mockAuthService.createNewContact(any, any)).thenAnswer((_) => Future.value(testContact));
      when(mockAuthService.createNewConversation(any, any)).thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verify(mockAuthService.createNewContact(testInboxIdentifier, testUser));
      verify(mockAuthService.createNewConversation(testInboxIdentifier, testContact.contactIdentifier));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockRequestHandler.next(any));

    });

    test('Given persisted conversation is null when a request is made, then create a conversation and submit request', () async{

      //GIVEN
      final testRequest = RequestOptions(path: "/");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(null);
      when(mockAuthService.createNewConversation(any, any)).thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verify(mockAuthService.createNewConversation(testInboxIdentifier, testContact.contactIdentifier));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockRequestHandler.next(any));

    });

    test('Given persisted contact exists when a request that needs authorization is made, then attach auth token and submit request', () async{

      //GIVEN
      final testHeaders = new Map<String, dynamic>();
      testHeaders.putIfAbsent("AUTHORIZATION", () => ChatwootClientApiInterceptor.INTERCEPTOR_AUTHORIZATION_PLACEHOLDER);
      final testRequest = RequestOptions(path: "/",headers: testHeaders);

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verifyNever(mockAuthService.createNewContact(testInboxIdentifier, testUser));
      verifyNever(mockAuthService.createNewConversation(testInboxIdentifier, testContact.contactIdentifier));
      verifyNever(mockContactDao.saveContact(testContact));
      verifyNever(mockConversationDao.saveConversation(testConversation));
      verify(
          mockRequestHandler.next(
              argThat(_HasAuthorizationHeader(testContact.pubsubToken))
          )
      );

    });

    test('Given contact identifier is needed when a request is made, then attach contact identifier and submit request', () async{

      //GIVEN
      final testRequest = RequestOptions(path: "/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verify(
          mockRequestHandler.next(
              argThat(_HasPath("/${testContact.contactIdentifier}"))
          )
      );

    });

    test('Given inbox identifier is needed when a request is made, then attach inbox identifier and submit request', () async{

      //GIVEN
      final testRequest = RequestOptions(path: "/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verify(
          mockRequestHandler.next(
              argThat(_HasPath("/$testInboxIdentifier"))
          )
      );

    });

    test('Given conversation identifier is needed when a request is made, then attach conversation identifier and submit request', () async{

      //GIVEN
      final testRequest = RequestOptions(path: "/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest,mockRequestHandler);

      //THEN
      verify(
          mockRequestHandler.next(
              argThat(_HasPath("/${testConversation.id}"))
          )
      );

    });

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
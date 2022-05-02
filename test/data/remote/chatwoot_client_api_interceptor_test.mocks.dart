// Mocks generated by Mockito 5.0.15 from annotations
// in chatwoot_client_sdk/test/data/remote/chatwoot_client_api_interceptor_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i7;

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart'
    as _i4;
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart'
    as _i5;
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart'
    as _i13;
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_auth_service.dart'
    as _i11;
import 'package:dio/dio.dart' as _i6;
import 'package:dio/src/dio.dart' as _i3;
import 'package:dio/src/dio_error.dart' as _i9;
import 'package:dio/src/dio_mixin.dart' as _i2;
import 'package:dio/src/options.dart' as _i10;
import 'package:dio/src/response.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;
import 'package:web_socket_channel/web_socket_channel.dart' as _i12;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeInterceptorState_0<T> extends _i1.Fake
    implements _i2.InterceptorState<T> {}

class _FakeDio_1 extends _i1.Fake implements _i3.Dio {}

class _FakeChatwootContact_2 extends _i1.Fake implements _i4.ChatwootContact {}

class _FakeChatwootConversation_3 extends _i1.Fake
    implements _i5.ChatwootConversation {}

/// A class which mocks [ResponseInterceptorHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockResponseInterceptorHandler extends _i1.Mock
    implements _i6.ResponseInterceptorHandler {
  MockResponseInterceptorHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i2.InterceptorState<dynamic>> get future =>
      (super.noSuchMethod(Invocation.getter(#future),
              returnValue: Future<_i2.InterceptorState<dynamic>>.value(
                  _FakeInterceptorState_0<dynamic>()))
          as _i7.Future<_i2.InterceptorState<dynamic>>);
  @override
  bool get isCompleted =>
      (super.noSuchMethod(Invocation.getter(#isCompleted), returnValue: false)
          as bool);
  @override
  void next(_i8.Response<dynamic>? response) =>
      super.noSuchMethod(Invocation.method(#next, [response]),
          returnValueForMissingStub: null);
  @override
  void resolve(_i8.Response<dynamic>? response) =>
      super.noSuchMethod(Invocation.method(#resolve, [response]),
          returnValueForMissingStub: null);
  @override
  void reject(_i9.DioError? error,
          [bool? callFollowingErrorInterceptor = false]) =>
      super.noSuchMethod(
          Invocation.method(#reject, [error, callFollowingErrorInterceptor]),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}

/// A class which mocks [RequestInterceptorHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockRequestInterceptorHandler extends _i1.Mock
    implements _i6.RequestInterceptorHandler {
  MockRequestInterceptorHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i2.InterceptorState<dynamic>> get future =>
      (super.noSuchMethod(Invocation.getter(#future),
              returnValue: Future<_i2.InterceptorState<dynamic>>.value(
                  _FakeInterceptorState_0<dynamic>()))
          as _i7.Future<_i2.InterceptorState<dynamic>>);
  @override
  bool get isCompleted =>
      (super.noSuchMethod(Invocation.getter(#isCompleted), returnValue: false)
          as bool);
  @override
  void next(_i10.RequestOptions? requestOptions) =>
      super.noSuchMethod(Invocation.method(#next, [requestOptions]),
          returnValueForMissingStub: null);
  @override
  void resolve(_i8.Response<dynamic>? response,
          [bool? callFollowingResponseInterceptor = false]) =>
      super.noSuchMethod(
          Invocation.method(
              #resolve, [response, callFollowingResponseInterceptor]),
          returnValueForMissingStub: null);
  @override
  void reject(_i9.DioError? error,
          [bool? callFollowingErrorInterceptor = false]) =>
      super.noSuchMethod(
          Invocation.method(#reject, [error, callFollowingErrorInterceptor]),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}

/// A class which mocks [ChatwootClientAuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockChatwootClientAuthService extends _i1.Mock
    implements _i11.ChatwootClientAuthService {
  MockChatwootClientAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set connection(_i12.WebSocketChannel? _connection) =>
      super.noSuchMethod(Invocation.setter(#connection, _connection),
          returnValueForMissingStub: null);
  @override
  _i3.Dio get dio =>
      (super.noSuchMethod(Invocation.getter(#dio), returnValue: _FakeDio_1())
          as _i3.Dio);
  @override
  _i7.Future<_i4.ChatwootContact> createNewContact(
          String? inboxIdentifier, _i13.ChatwootUser? user) =>
      (super.noSuchMethod(
              Invocation.method(#createNewContact, [inboxIdentifier, user]),
              returnValue:
                  Future<_i4.ChatwootContact>.value(_FakeChatwootContact_2()))
          as _i7.Future<_i4.ChatwootContact>);
  @override
  _i7.Future<_i5.ChatwootConversation> createNewConversation(
          String? inboxIdentifier, String? contactIdentifier) =>
      (super.noSuchMethod(
              Invocation.method(
                  #createNewConversation, [inboxIdentifier, contactIdentifier]),
              returnValue: Future<_i5.ChatwootConversation>.value(
                  _FakeChatwootConversation_3()))
          as _i7.Future<_i5.ChatwootConversation>);
  @override
  String toString() => super.toString();
}


import 'dart:async';
import 'dart:convert';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class ChatwootClientService{

  final String _baseUrl;
  WebSocketChannel? connection;
  final Dio _dio;

  ChatwootClientService(this._baseUrl, this._dio);

  Future<ChatwootContact> updateContact(
      update
  );

  Future<ChatwootContact> getContact();

  Future<List<ChatwootConversation>> getConversations();

  Future<ChatwootConversation> createMessage(
      ChatwootNewMessageRequest request
  );

  Future<ChatwootConversation> updateMessage(
      String messageIdentifier,
      update
  );

  Future<List<ChatwootMessage>> getAllMessages();

  Future<ChatwootContact> createNewContact(ChatwootUser? user);

  Future<ChatwootConversation> createNewConversation(String contactIdentifier);

  void startWebSocketConnection(
      String contactPubsubToken
  );

}

class ChatwootClientServiceImpl extends ChatwootClientService{

  ChatwootClientServiceImpl(
      String baseUrl,
      {
        required Dio dio
      }
  ) : super(baseUrl, dio);


  Future<ChatwootContact> createNewContact(ChatwootUser? user) async{
    try{
      final createResponse = await _dio.post(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts",
          data: user
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        //creating contact successful continue with request
        final contact = ChatwootContact.fromJson(createResponse.data);
        return contact;
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  Future<ChatwootConversation> createNewConversation(String contactIdentifier) async{
    try{
      final createResponse = await _dio.post(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/$contactIdentifier/conversations"
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        //creating contact successful continue with request
        final newConversation = ChatwootConversation.fromJson(createResponse.data);
        return newConversation;
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<ChatwootConversation> createMessage(
      ChatwootNewMessageRequest request
  ) async{
    try{
      final createResponse = await _dio.post(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages"
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        return ChatwootConversation.fromJson(createResponse.data);
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<List<ChatwootMessage>> getAllMessages() async{
    try{
      final createResponse = await _dio.get(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages"
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        return (createResponse.data as List<dynamic>)
            .map(((json)=>ChatwootMessage.fromJson(createResponse.data)))
            .toList();
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<ChatwootContact> getContact() async{
    try{
      final createResponse = await _dio.post("public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        return ChatwootContact.fromJson(createResponse.data);
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<List<ChatwootConversation>> getConversations() async{
    try{
      final createResponse = await _dio.post("public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations");
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        return (createResponse.data as List<dynamic>)
            .map(((json)=>ChatwootConversation.fromJson(createResponse.data)))
            .toList();
      }else{
        throw ChatwootClientException(createResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<ChatwootContact> updateContact(
      update
  ) async{
    try{
      final updateResponse = await _dio.patch(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          data: update
      );
      if((updateResponse.statusCode ?? 0).isBetween(199, 300) ){
        return ChatwootContact.fromJson(updateResponse.data);
      }else{
        throw ChatwootClientException(updateResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  Future<ChatwootConversation> updateMessage(
      String messageIdentifier,
      update
  ) async{
    try{
      final updateResponse = await _dio.patch(
          "public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages/$messageIdentifier",
          data: update
      );
      if((updateResponse.statusCode ?? 0).isBetween(199, 300) ){
        return ChatwootConversation.fromJson(updateResponse.data);
      }else{
        throw ChatwootClientException(updateResponse.statusMessage ?? "unknown error");
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message);
    }
  }

  @override
  void startWebSocketConnection(
      String contactPubsubToken
  ) {
    if(this.connection == null){
      final socketUrl = Uri.parse(_baseUrl.replaceFirst("http", "ws")+"/cable");
      this.connection = WebSocketChannel.connect(socketUrl);
    }
    connection?.sink.add(jsonEncode({
      "command":"subscribe",
      "identifier": jsonEncode({
        "channel":"RoomChannel",
        "pubsub_token": contactPubsubToken
      })
    }));
  }


}
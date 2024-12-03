import 'dart:async';
import 'dart:convert';

import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

/// Service for handling chatwoot api calls
/// See [ChatwootClientServiceImpl]
abstract class ChatwootClientService {
  final String _baseUrl;
  WebSocketChannel? connection;
  final Dio _dio;
  final Dio _udio;

  ChatwootClientService(this._baseUrl, this._dio, this._udio);

  Future<ChatwootContact> updateContact(update);

  Future<ChatwootContact> getContact();

  Future<List<ChatwootConversation>> getConversations();

  Future<ChatwootMessage> createMessage(ChatwootNewMessageRequest request);

  Future<ChatwootMessage> updateMessage(String messageIdentifier, update);

  Future<CsatSurveyFeedbackResponse> sendCsatFeedBack(
      String conversationUuid, SendCsatSurveyRequest request);

  Future<CsatSurveyFeedbackResponse?> getCsatFeedback(String conversationUuid);

  Future<List<ChatwootMessage>> getAllMessages();

  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection});

  void sendAction(String contactPubsubToken, ChatwootActionType action);
}

class ChatwootClientServiceImpl extends ChatwootClientService {
  ChatwootClientServiceImpl(String baseUrl,
      {required Dio dio, required Dio uDio})
      : super(baseUrl, dio, uDio);

  ///Sends message to chatwoot inbox
  @override
  Future<ChatwootMessage> createMessage(
      ChatwootNewMessageRequest request) async {
    try {
      FormData formData = FormData.fromMap({
        'echo_id': request.echoId,
        'content': request.content,
      });
      for (final attachment in request.attachments) {
        formData.files.add(MapEntry(
            'attachments[]',
            await MultipartFile.fromBytes(
              attachment.bytes,
              filename: attachment.name,
              contentType: MediaType.parse(lookupMimeType(attachment.name) ??
                  'application/octet-stream'),
            )));
      }
      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages",
          data: formData);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        final message = ChatwootMessage.fromJson(createResponse.data);

        return message;
      } else {
        throw ChatwootClientException(
            createResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.SEND_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.SEND_MESSAGE_FAILED);
    }
  }

  ///Gets all messages of current chatwoot client instance's conversation
  @override
  Future<List<ChatwootMessage>> getAllMessages() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        final messages = (createResponse.data as List<dynamic>)
            .map(((json) => ChatwootMessage.fromJson(json)))
            .toList();
        return messages;
      } else {
        throw ChatwootClientException(
            createResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.GET_MESSAGES_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.GET_MESSAGES_FAILED);
    }
  }

  ///Gets contact of current chatwoot client instance
  @override
  Future<ChatwootContact> getContact() async {
    try {
      final getResponse = await _dio.get(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");
      if ((getResponse.statusCode ?? 0).isBetween(199, 300)) {
        return ChatwootContact.fromJson(getResponse.data);
      } else {
        throw ChatwootClientException(
            getResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.GET_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.GET_CONTACT_FAILED);
    }
  }

  ///Gets all conversation of current chatwoot client instance
  @override
  Future<List<ChatwootConversation>> getConversations() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => ChatwootConversation.fromJson(json)))
            .toList();
      } else {
        throw ChatwootClientException(
            createResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.GET_CONVERSATION_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.GET_CONVERSATION_FAILED);
    }
  }

  ///Update current client instance's contact
  @override
  Future<ChatwootContact> updateContact(update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return ChatwootContact.fromJson(updateResponse.data);
      } else {
        throw ChatwootClientException(
            updateResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.UPDATE_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.UPDATE_CONTACT_FAILED);
    }
  }

  ///Update message with id [messageIdentifier] with contents of [update]
  @override
  Future<ChatwootMessage> updateMessage(
      String messageIdentifier, update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${ChatwootClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${ChatwootClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${ChatwootClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages/$messageIdentifier",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        final message = ChatwootMessage.fromJson(updateResponse.data);
        return message;
      } else {
        throw ChatwootClientException(
            updateResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.UPDATE_MESSAGE_FAILED);
    }
  }

  @override
  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection}) {
    final socketUrl = Uri.parse(_baseUrl.replaceFirst("http", "ws") + "/cable");
    this.connection = onStartConnection == null
        ? WebSocketChannel.connect(socketUrl)
        : onStartConnection(socketUrl);
    connection!.sink.add(jsonEncode({
      "command": "subscribe",
      "identifier": jsonEncode(
          {"channel": "RoomChannel", "pubsub_token": contactPubsubToken})
    }));
  }

  @override
  void sendAction(String contactPubsubToken, ChatwootActionType actionType) {
    final ChatwootAction action;
    final identifier = jsonEncode(
        {"channel": "RoomChannel", "pubsub_token": contactPubsubToken});
    switch (actionType) {
      case ChatwootActionType.subscribe:
        action = ChatwootAction(identifier: identifier, command: "subscribe");
        break;
      default:
        action = ChatwootAction(
            identifier: identifier,
            data: ChatwootActionData(action: actionType),
            command: "message");
        break;
    }
    connection?.sink.add(jsonEncode(action.toJson()));
  }

  @override
  Future<CsatSurveyFeedbackResponse?> getCsatFeedback(
      String conversationUuid) async {
    try {
      final response =
          await _dio.get("/public/api/v1/csat_survey/$conversationUuid");
      if ((response.statusCode ?? 0).isBetween(199, 300)) {
        return response.data != null
            ? CsatSurveyFeedbackResponse.fromJson(response.data)
            : null;
      } else {
        throw ChatwootClientException(response.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.GET_CSAT_FEEDBACK);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.GET_CSAT_FEEDBACK);
    }
  }

  @override
  Future<CsatSurveyFeedbackResponse> sendCsatFeedBack(
      String conversationUuid, SendCsatSurveyRequest request) async {
    try {
      final response = await _udio
          .put("/public/api/v1/csat_survey/$conversationUuid", data: {
        "message": {
          "submitted_values": {"csat_survey_response": request.toJson()}
        }
      });
      if ((response.statusCode ?? 0).isBetween(199, 300)) {
        return CsatSurveyFeedbackResponse.fromJson(response.data);
      } else {
        throw ChatwootClientException(response.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.SEND_CSAT_FEEDBACK);
      }
    } on DioError catch (e) {
      throw ChatwootClientException(
          e.message ?? "", ChatwootClientExceptionType.SEND_CSAT_FEEDBACK);
    }
  }
}

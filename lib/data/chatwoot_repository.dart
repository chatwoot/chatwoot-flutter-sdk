import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/local/local_storage.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';
import 'package:chatwoot_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:flutter/material.dart';

/// Handles interactions between chatwoot client api service[clientService] and
/// [localStorage] if persistence is enabled.
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
abstract class ChatwootRepository {
  @protected
  final ChatwootClientService clientService;
  @protected
  final LocalStorage localStorage;
  @protected
  ChatwootCallbacks callbacks;
  List<StreamSubscription> _subscriptions = [];

  ChatwootRepository(this.clientService, this.localStorage, this.callbacks);

  Future<void> initialize(ChatwootUser? user);

  void getPersistedMessages();

  Future<void> getMessages();

  void listenForEvents();

  Future<void> sendMessage(ChatwootNewMessageRequest request);

  void sendAction(ChatwootActionType action);

  Future<void> sendCsatFeedBack(String conversationUuid, SendCsatSurveyRequest request);

  Future<void> clear();

  void dispose();
}

class ChatwootRepositoryImpl extends ChatwootRepository {
  bool _isListeningForEvents = false;
  Timer? _publishPresenceTimer;
  Timer? _presenceResetTimer;
  Timer? _checkPingTimer;
  DateTime? _lastPingTime;

  ChatwootRepositoryImpl(
      {required ChatwootClientService clientService,
      required LocalStorage localStorage,
      required ChatwootCallbacks streamCallbacks})
      : super(clientService, localStorage, streamCallbacks);

  /// Fetches persisted messages.
  ///
  /// Calls [ChatwootCallbacks.onMessagesRetrieved] when [ChatwootClientService.getAllMessages] is successful
  /// Calls [ChatwootCallbacks.onError] when [ChatwootClientService.getAllMessages] fails
  @override
  Future<void> getMessages() async {
    try {
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      callbacks.onMessagesRetrieved?.call(messages);
    } on ChatwootClientException catch (e) {
      callbacks.onError?.call(e);
    }
  }

  /// Fetches persisted messages.
  ///
  /// Calls [ChatwootCallbacks.onPersistedMessagesRetrieved] if persisted messages are found
  @override
  void getPersistedMessages() {
    final persistedMessages = localStorage.messagesDao.getMessages();
    if (persistedMessages.isNotEmpty) {
      callbacks.onPersistedMessagesRetrieved?.call(persistedMessages);
    }
  }

  /// Initializes chatwoot client repository
  Future<void> initialize(ChatwootUser? user) async {
    try {
      if (user != null) {
        await localStorage.userDao.saveUser(user);
      }

      //refresh contact
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);

      //refresh conversation
      final conversations = await clientService.getConversations();
      final persistedConversation =
          localStorage.conversationDao.getConversation()!;
      final refreshedConversation = conversations.firstWhere(
          (element) => element.id == persistedConversation.id,
          orElse: () =>
              persistedConversation //highly unlikely orElse will be called but still added it just in case
          );
      localStorage.conversationDao.saveConversation(refreshedConversation);
    } on ChatwootClientException catch (e) {
      callbacks.onError?.call(e);
    }

    listenForEvents();
  }

  ///Sends message to chatwoot inbox
  Future<void> sendMessage(ChatwootNewMessageRequest request) async {
    try {
      final createdMessage = await clientService.createMessage(request);
      await localStorage.messagesDao.saveMessage(createdMessage);
      callbacks.onMessageSent?.call(createdMessage, request.echoId);
      if (clientService.connection != null && !_isListeningForEvents) {
        listenForEvents();
      }
    } on ChatwootClientException catch (e) {
      callbacks.onError?.call(
          ChatwootClientException(e.cause, e.type, data: request.echoId));
    }
  }

  @override
  Future<void> sendCsatFeedBack(String conversationUuid, SendCsatSurveyRequest request) async{
    try {
      CsatSurveyFeedbackResponse feedback = await clientService.sendCsatFeedBack(conversationUuid, request);
      if(feedback.csatSurveyResponse == null){
        feedback = CsatSurveyFeedbackResponse(
            id: feedback.id,
            csatSurveyResponse: CsatResponse(
                id:feedback.id,
                conversationId: feedback.conversationId,
                rating: request.rating,
                feedbackMessage: request.feedbackMessage
            ),
            inboxAvatarUrl: feedback.inboxAvatarUrl,
            inboxName: feedback.inboxName,
            createdAt: feedback.createdAt,
            conversationId: feedback.conversationId
        );
      }
      callbacks.onCsatSurveyResponseRecorded?.call(feedback);
    } on ChatwootClientException catch (e) {
      callbacks.onError?.call(
          ChatwootClientException(e.cause, e.type));
    }
  }

  /// Connects to chatwoot websocket and starts listening for updates
  ///
  /// Received events/messages are pushed through [ChatwootClient.callbacks]
  @override
  void listenForEvents(){
    final token = localStorage.contactDao.getContact()?.pubsubToken;
    if (token == null) {
      return;
    }
    clientService.startWebSocketConnection(
        localStorage.contactDao.getContact()!.pubsubToken ?? "");

    final newSubscription = clientService.connection!.stream.listen(
            (event) async{
      ChatwootEvent chatwootEvent = ChatwootEvent.fromJson(jsonDecode(event));
      if (chatwootEvent.type == ChatwootEventType.welcome) {
        callbacks.onWelcome?.call();
      } else if (chatwootEvent.type == ChatwootEventType.ping) {
        if(_lastPingTime == null){
          _startPingCheck();
        }
        _lastPingTime = DateTime.now();
        callbacks.onPing?.call();
      } else if (chatwootEvent.type == ChatwootEventType.confirm_subscription) {
        if (!_isListeningForEvents) {
          _isListeningForEvents = true;
        }
        _publishPresenceUpdates();
        callbacks.onConfirmedSubscription?.call();
      } else if (chatwootEvent.message?.event ==
          ChatwootEventMessageType.message_created) {
        print("here comes message: $event");

        final ChatwootMessage message = chatwootEvent.message!.data!.getMessage();

        localStorage.messagesDao.saveMessage(message);
        if (message.isMine) {
          callbacks.onMessageDelivered
              ?.call(message, chatwootEvent.message!.data!.echoId!);
        } else {
          callbacks.onMessageReceived?.call(message);
        }
      } else if (chatwootEvent.message?.event ==
          ChatwootEventMessageType.message_updated) {
        print("here comes the updated message: $event");


        final ChatwootMessage message = chatwootEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);

        callbacks.onMessageUpdated?.call(message);
      } else if (chatwootEvent.message?.event ==
          ChatwootEventMessageType.conversation_typing_off) {
        callbacks.onConversationStoppedTyping?.call();
      } else if (chatwootEvent.message?.event ==
          ChatwootEventMessageType.conversation_typing_on) {
        callbacks.onConversationStartedTyping?.call();
      } else if (chatwootEvent.message?.event ==
              ChatwootEventMessageType.conversation_status_changed &&
          chatwootEvent.message?.data?.status == "resolved" &&
          chatwootEvent.message?.data?.id ==
              (localStorage.conversationDao.getConversation()?.id ?? 0)) {
        //delete conversation result
        final conversationUuid = localStorage.conversationDao.getConversation()?.uuid ??'';
        localStorage.conversationDao.deleteConversation();
        localStorage.messagesDao.clear();
        callbacks.onConversationResolved?.call(conversationUuid);
      } else if (chatwootEvent.message?.event ==
          ChatwootEventMessageType.presence_update) {
        final presenceStatuses =
            (chatwootEvent.message!.data!.users as Map<dynamic, dynamic>)
                .values;
        final isOnline = presenceStatuses.contains("online");
        if (isOnline) {
          callbacks.onConversationIsOnline?.call();
          _presenceResetTimer?.cancel();
          _startPresenceResetTimer();
        } else {
          callbacks.onConversationIsOffline?.call();
        }
      } else {
        print("chatwoot unknown event: $event");
      }
    },
    onError: (e){
      //auto reconnect on error
      print("chatwoot websocket: $e");
      listenForEvents();
    });
    _subscriptions.add(newSubscription);
  }

  /// Clears all data related to current chatwoot client instance
  @override
  Future<void> clear() async {
    await localStorage.clear();
  }

  /// Cancels websocket stream subscriptions and disposes [localStorage]
  @override
  void dispose() {
    localStorage.dispose();
    callbacks = ChatwootCallbacks();
    _presenceResetTimer?.cancel();
    _publishPresenceTimer?.cancel();
    _checkPingTimer?.cancel();
    _subscriptions.forEach((subs) {
      subs.cancel();
    });
  }

  ///Send actions like user started typing
  @override
  void sendAction(ChatwootActionType action) {
    clientService.sendAction(
        localStorage.contactDao.getContact()!.pubsubToken ?? "", action);
  }

  /// Start a timer to check for missed pings
  void _startPingCheck() {
    _checkPingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (_lastPingTime != null &&
          now.difference(_lastPingTime!).inSeconds > 30) {
        print("No ping received in 30 seconds. Reconnecting...");
        _lastPingTime = null;
        _checkPingTimer?.cancel();
        _checkPingTimer = null;
        listenForEvents();
        //get any lost messages
        getMessages();
      }
    });
  }

  ///Publishes presence update to websocket channel at a 30 second interval
  void _publishPresenceUpdates() {
    sendAction(ChatwootActionType.update_presence);
    _publishPresenceTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      sendAction(ChatwootActionType.update_presence);
    });
  }

  ///Triggers an offline presence event after 40 seconds without receiving a presence update event
  void _startPresenceResetTimer() {
    _presenceResetTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      callbacks.onConversationIsOffline?.call();
      _presenceResetTimer?.cancel();
    });
  }
}

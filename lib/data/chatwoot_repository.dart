
import 'dart:async';
import 'dart:core';

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_client_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:flutter/material.dart';

/// Handles interactions between chatwoot client api service[clientService] and
/// [localStorage] if persistence is enabled.
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
abstract class ChatwootRepository{
  @protected final ChatwootClientService clientService;
  @protected final LocalStorage localStorage;
  @protected ChatwootCallbacks callbacks;
  List<StreamSubscription> _subscriptions = [];

  ChatwootRepository(
    this.clientService,
    this.localStorage,
    this.callbacks
  );

  /// Initializes client contact
  Future<void> initialize(ChatwootUser? user);

  /// Fetches persisted messages.
  ///
  /// Calls [callbacks.onPersistedMessagesRetrieved] if persisted messages are found
  void getPersistedMessages();


  /// Fetches persisted messages.
  ///
  /// Calls [callbacks.onMessagesRetrieved] when [clientService.getAllMessages] is successful
  /// Calls [callbacks.onError] when [clientService.getAllMessages] fails
  Future<void> getMessages();

  /// Connects to chatwoot websocket and starts listening for updates
  ///
  /// Calls [callbacks.onWelcome] when websocket welcome event is received
  /// Calls [callbacks.onPing] when websocket ping event is received
  /// Calls [callbacks.onConfirmedSubscription] when websocket subscription confirmation event is received
  /// Calls [callbacks.onMessageCreated] when websocket message created event is received, and
  /// message doesn't belong to current user
  /// Calls [callbacks.onMyMessageSent] when websocket message created event is received, and message belongs
  /// to current user
  void listenForEvents();

  ///Save user object to local storage
  Future<void> sendMessage(ChatwootNewMessageRequest request);

  ///Send actions like user started typing
  void sendAction(ChatwootActionType action);

  /// Clears all data related to current chatwoot client instance
  Future<void> clear();


  /// Cancels websocket stream subscriptions and disposes [localStorage]
  void dispose();

}


class ChatwootRepositoryImpl extends ChatwootRepository{


  ChatwootRepositoryImpl({
    required ChatwootClientService clientService,
    required LocalStorage localStorage,
    required ChatwootCallbacks streamCallbacks
  }):super(
      clientService,
      localStorage,
      streamCallbacks
  );

  @override
  Future<void> getMessages() async{
    try{
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      callbacks.onMessagesRetrieved?.call(messages);
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e);
    }
  }

  @override
  void getPersistedMessages() {
    final persistedMessages = localStorage.messagesDao.getMessages();
    if(persistedMessages.isNotEmpty){
      callbacks.onPersistedMessagesRetrieved?.call(persistedMessages);
    }
  }

  Future<void> initialize(ChatwootUser? user) async{

    if(user != null){
      await localStorage.userDao.saveUser(user);
      //refresh contact
      final contact = await clientService.updateContact(user.toJson());
      localStorage.contactDao.saveContact(contact);
    }else{
      //refresh contact
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);
    }

    //refresh conversation
    final conversations = await clientService.getConversations();
    final persistedConversation = localStorage.conversationDao.getConversation()!;
    final refreshedConversation = conversations.firstWhere(
            (element) => element.id == persistedConversation.id,
            orElse: ()=>persistedConversation //highly unlikely orElse will be called but still added it just in case
    );
    localStorage.conversationDao.saveConversation(refreshedConversation);

    listenForEvents();
  }


  Future<void> sendMessage(ChatwootNewMessageRequest request) async{
    try{
      final createdMessage = await clientService.createMessage(request);
      await localStorage.messagesDao.saveMessage(createdMessage);
      callbacks.onMessageSent?.call(createdMessage, request.echoId);
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e);
    }
  }

  @override
  void listenForEvents() {
    clientService.startWebSocketConnection(localStorage.contactDao.getContact()!.pubsubToken);
    final newSubscription = clientService.connection!.stream.listen((event) {
      ChatwootEvent chatwootEvent = ChatwootEvent.fromJson(event);
      if(chatwootEvent.type == ChatwootEventType.welcome){
        callbacks.onWelcome?.call();
      }else if(chatwootEvent.type == ChatwootEventType.ping){
        callbacks.onPing?.call();
      }else if(chatwootEvent.type == ChatwootEventType.confirm_subscription){
        callbacks.onConfirmedSubscription?.call();
      }else if(chatwootEvent.message?.event == ChatwootEventMessageType.message_created){
        print("here comes message: $event");
        final message = chatwootEvent.message!.data!.getMessage();
        if(message.isMine){
          callbacks.onMessageDelivered?.call(message, chatwootEvent.message!.data!.echoId!);
        }else{
          callbacks.onMessageReceived?.call(message);
        }
      }else if(chatwootEvent.message?.event == ChatwootEventMessageType.conversation_typing_off){
        callbacks.onConversationStoppedTyping?.call();
      }else if(chatwootEvent.message?.event == ChatwootEventMessageType.conversation_typing_on){
        callbacks.onConversationStartedTyping?.call();
      }else if(chatwootEvent.message?.event == ChatwootEventMessageType.presence_update){
        final presenceStatuses = (chatwootEvent.message!.data!.users as Map<dynamic, dynamic>).values;
        final isOnline = presenceStatuses.contains("online");
        if(isOnline){
          callbacks.onConversationIsOnline?.call();
        }else{
          callbacks.onConversationIsOffline?.call();
        }
      }else{
        print("chatwoot unknown event: $event");
      }
    });
    _subscriptions.add(newSubscription);
  }

  @override
  Future<void> clear() async {
    await localStorage.clear();
  }

  @override
  void dispose() {
    localStorage.dispose();
    callbacks = ChatwootCallbacks();
    _subscriptions.forEach((subs) { subs.cancel();});
  }

  @override
  void sendAction(ChatwootActionType action) {
    clientService.sendAction(localStorage.contactDao.getContact()!.pubsubToken, action);
  }

}

import 'dart:async';
import 'dart:core';

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
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
  Future<void> saveUser(ChatwootUser user);

  ///Save user object to local storage
  Future<void> sendMessage(ChatwootNewMessageRequest request);

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
    try{
      await localStorage.openDB();

      if(user != null){
        await localStorage.userDao.saveUser(user);
      }

      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);
      listenForEvents();
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e);
    }
  }


  @override
  Future<void> saveUser(ChatwootUser user) async{
    await localStorage.userDao.saveUser(user);
  }


  Future<void> sendMessage(ChatwootNewMessageRequest request) async{
    try{
      await clientService.createMessage(request);
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e);
    }
  }

  @override
  void listenForEvents() {
    clientService.startWebSocketConnection(localStorage.contactDao.getContact()!.pubsubToken);
    final newSubscription = clientService.connection!.stream.listen((event) {
      if(event["type"] == "welcome"){
        callbacks.onWelcome?.call(event);
      }else if(event["type"] == "ping"){
        callbacks.onPing?.call(event);
      }else if(event["type"] == "confirm_subscription"){
        callbacks.onConfirmedSubscription?.call(event);
      }else if(event["message"]["event"] == "message.created"){
        print("here comes message: $event");
        if(event["message"]["data"]["message_type"] == 1){
          callbacks.onMessageCreated?.call(ChatwootMessage.fromJson(event["message"]["data"]));
        }else{
          callbacks.onMyMessageSent?.call(ChatwootMessage.fromJson(event["message"]["data"]));
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

}
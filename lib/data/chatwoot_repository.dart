
import 'dart:async';
import 'dart:core';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_service.dart';
import 'package:flutter/material.dart';


abstract class ChatwootRepository{
  @protected final ChatwootClientService clientService;
  @protected final LocalStorage localStorage;
  @protected final ChatwootCallbacks callbacks;
  List<StreamSubscription> _subscriptions = [];

  ChatwootRepository(
    this.clientService,
    this.localStorage,
    this.callbacks
  );


  Future<void> initialize();
  List<ChatwootMessage> getPersistedMessages();
  Future<List<ChatwootMessage>> getMessages();
  void listenForEvents();
  Future<void> saveUser(ChatwootUser user);
  void dispose();

}

class ChatwootCallbacks{
  void Function(dynamic)? onWelcome;
  void Function(dynamic)? onPing;
  void Function(dynamic)? onConfirmedSubscription;
  void Function(ChatwootMessage)? onMessageCreated;
  void Function(ChatwootMessage)? onMyMessageSent;
  void Function(String)? onError;

  ChatwootCallbacks({
    this.onWelcome,
    this.onPing,
    this.onConfirmedSubscription,
    this.onMessageCreated,
    this.onMyMessageSent,
    this.onError,
  });
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
  Future<List<ChatwootMessage>> getMessages() async{
    await initialize();
    try{
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      return messages;
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e.cause);
      return [];
    }
  }

  @override
  List<ChatwootMessage> getPersistedMessages() {
    return localStorage.messagesDao.getMessages();
  }

  Future<void> initialize() async{
    try{
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);
      listenForEvents();
    }on ChatwootClientException catch(e){
      callbacks.onError?.call(e.cause);
    }
  }


  @override
  Future<void> saveUser(ChatwootUser user) async{
    await localStorage.userDao.saveUser(user);
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
  void dispose() {
    localStorage.dispose();
    _subscriptions.forEach((subs) { subs.cancel();});
  }

}
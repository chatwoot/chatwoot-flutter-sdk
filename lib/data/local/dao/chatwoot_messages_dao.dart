
import 'dart:collection';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:hive_flutter/hive_flutter.dart';


abstract class ChatwootMessagesDao{
  Future<void> saveMessage(ChatwootMessage message);
  Future<void> saveAllMessages(List<ChatwootMessage> messages);
  ChatwootMessage? getMessage(String messageId);
  List<ChatwootMessage> getMessages();
  Future<void> clear();
  Future<void> deleteMessage(String messageId);
  void onDispose();
}

class PersistedChatwootMessagesDao extends ChatwootMessagesDao{
  // box containing all persisted messages
  final Box<ChatwootMessage> box;

  final String baseUrl;
  final String inboxIdentifier;
  final String? userIdentifier;

  //box with many to one relation
  final Box<String> messageIdToGeneratedClientInstanceKeyBox;

  PersistedChatwootMessagesDao(
    this.box,
    this.messageIdToGeneratedClientInstanceKeyBox,{
    required this.baseUrl,
    required this.inboxIdentifier,
    this.userIdentifier
  });

  final keySeparator= "|||";

  String getMessageGeneratedClientInstanceKey(){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier${keySeparator}messages";
  }

  @override
  Future<void> clear() async{
    final messageClientInstancekey = getMessageGeneratedClientInstanceKey();

    //filter current client instance message ids
    Iterable clientMessageIds = messageIdToGeneratedClientInstanceKeyBox
        .keys
        .where((key) => messageIdToGeneratedClientInstanceKeyBox.get(key) == messageClientInstancekey);

    await box.deleteAll(clientMessageIds);
  }

  @override
  Future<void> saveMessage(ChatwootMessage message) async{
    await box.put(message.id, message);
    await messageIdToGeneratedClientInstanceKeyBox.put(message.id, getMessageGeneratedClientInstanceKey());
  }

  @override
  Future<void> saveAllMessages(List<ChatwootMessage> messages) async{
    messages.forEach((element) async{
      await saveMessage(element);
    });
  }

  @override
  List<ChatwootMessage> getMessages(){
    final messageClientInstancekey = getMessageGeneratedClientInstanceKey();

    //filter current client instance message ids
    Set<String> clientMessageIds = messageIdToGeneratedClientInstanceKeyBox
        .keys
        .where((key) => messageIdToGeneratedClientInstanceKeyBox.get(key) == messageClientInstancekey)
        .toSet() as Set<String>;

    //retrieve messages with ids
    List<ChatwootMessage> sortedMessages = box
        .values
        .where((message) => clientMessageIds.contains(message.id))
        .toList(growable: false);

    //sort message using creation dates
    sortedMessages.sort((a,b){
      return a.createdAt.compareTo(b.createdAt);
    });

    return sortedMessages;
  }

  @override
  void onDispose() {
    box.close();
  }

  @override
  Future<void> deleteMessage(String messageId) async{
    await box.delete(messageId);
    await messageIdToGeneratedClientInstanceKeyBox.delete(messageId);
  }

  @override
  ChatwootMessage? getMessage(String messageId) {
    return box.get(messageId,defaultValue: null);
  }

}

class NonPersistedChatwootMessagesDao extends ChatwootMessagesDao{
  HashMap<String, ChatwootMessage> messages = new HashMap();

  @override
  Future<void> clear() async{
    messages.clear();
  }

  @override
  Future<void> deleteMessage(String messageId) async{
    messages.remove(messageId);
  }

  @override
  ChatwootMessage? getMessage(String messageId) {
    return messages[messageId];
  }

  @override
  List<ChatwootMessage> getMessages() {
    List<ChatwootMessage> sortedMessages = messages.values.toList(growable: false);
    sortedMessages.sort((a,b){
      return a.createdAt.compareTo(b.createdAt);
    });
    return sortedMessages;
  }

  @override
  void onDispose() {
    messages.clear();
  }

  @override
  Future<void> saveAllMessages(List<ChatwootMessage> messages) async{
    messages.forEach((element) async{
      await saveMessage(element);
    });
  }

  @override
  Future<void> saveMessage(ChatwootMessage message) async{
    messages.update(message.id, (value) => message, ifAbsent: ()=>message);
  }

}
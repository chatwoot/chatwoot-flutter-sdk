
import 'dart:collection';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:hive_flutter/hive_flutter.dart';


abstract class ChatwootMessagesDao{
  Future<void> openDB();
  Future<void> saveMessage(ChatwootMessage message);
  Future<void> saveAllMessages(List<ChatwootMessage> messages);
  ChatwootMessage? getMessage(String messageId);
  List<ChatwootMessage> getMessages();
  Future<void> clear();
  Future<void> deleteMessage(String messageId);
  void onDispose();
}

//Only used when persistence is enabled
enum ChatwootMessagesBoxNames{
  MESSAGES, MESSAGES_TO_CLIENT_INSTANCE_KEY
}
class PersistedChatwootMessagesDao extends ChatwootMessagesDao{
  // box containing all persisted messages
  final Box<ChatwootMessage> box;

  final String clientInstanceKey;

  //box with many to one relation
  final Box<String> messageIdToClientInstanceKeyBox;

  PersistedChatwootMessagesDao(
    this.box,
    this.messageIdToClientInstanceKeyBox,{
    required this.clientInstanceKey
  });

  @override
  Future<void> clear() async{

    //filter current client instance message ids
    Iterable clientMessageIds = messageIdToClientInstanceKeyBox
        .keys
        .where((key) => messageIdToClientInstanceKeyBox.get(key) == clientInstanceKey);

    await box.deleteAll(clientMessageIds);
  }

  @override
  Future<void> saveMessage(ChatwootMessage message) async{
    await box.put(message.id, message);
    await messageIdToClientInstanceKeyBox.put(message.id, clientInstanceKey);
  }

  @override
  Future<void> saveAllMessages(List<ChatwootMessage> messages) async{
    messages.forEach((element) async{
      await saveMessage(element);
    });
  }

  @override
  List<ChatwootMessage> getMessages(){
    final messageClientInstancekey = clientInstanceKey;

    //filter current client instance message ids
    Set<String> clientMessageIds = messageIdToClientInstanceKeyBox
        .keys
        .where((key) => messageIdToClientInstanceKeyBox.get(key) == messageClientInstancekey)
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
    await messageIdToClientInstanceKeyBox.delete(messageId);
  }

  @override
  ChatwootMessage? getMessage(String messageId) {
    return box.get(messageId,defaultValue: null);
  }

  @override
  Future<void> openDB() async{
    ChatwootMessagesBoxNames.values.forEach((boxName) async{
      await Hive.openBox(boxName.toString());
    });
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

  @override
  Future<void> openDB() async{
    //nothing to do here
  }

}
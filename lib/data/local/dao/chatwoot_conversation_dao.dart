
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';


abstract class ChatwootConversationDao{
  Future<void> saveConversation(ChatwootConversation conversation);
  ChatwootConversation? getConversation();
  Future<void> deleteConversation();
  void onDispose();
}

class PersistedChatwootConversationDao extends ChatwootConversationDao{
  //box containing all persisted conversations
  Box<ChatwootConversation> box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> generatedClientInstanceIdToConversationIdentifierBox;
  String baseUrl;
  String inboxIdentifier;
  String? userIdentifier;

  PersistedChatwootConversationDao(
    this.box,
    this.generatedClientInstanceIdToConversationIdentifierBox,{
    required this.baseUrl,
    required this.inboxIdentifier,
    this.userIdentifier
  });

  final keySeparator= "|||";

  String getConversationGeneratedClientInstanceKey(){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier${keySeparator}conversation";
  }
  
  @override
  Future<void> deleteConversation() async{
    final conversationIdentifier = generatedClientInstanceIdToConversationIdentifierBox.get(
        getConversationGeneratedClientInstanceKey()
    );
    await generatedClientInstanceIdToConversationIdentifierBox.delete(
        getConversationGeneratedClientInstanceKey()
    );
    await box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(ChatwootConversation conversation) async{
    await generatedClientInstanceIdToConversationIdentifierBox.put(
        getConversationGeneratedClientInstanceKey(), 
        conversation.id.toString()
    );
    await box.put(conversation.id, conversation);
  }

  @override
  ChatwootConversation? getConversation() {
    if(box.values.length==0){
      return null;
    }
    
    final conversationidentifierString = generatedClientInstanceIdToConversationIdentifierBox.get(
        getConversationGeneratedClientInstanceKey()
    );
    final conversationIdentifier = int.tryParse(conversationidentifierString ?? "");

    if(conversationIdentifier == null){
      return null;
    }
    
    return box.get(conversationIdentifier);
  }

  @override
  void onDispose() {
    box.close();
  }

}

class NonPersistedChatwootConversationDao extends ChatwootConversationDao{

  ChatwootConversation? conversation;

  @override
  Future<void> deleteConversation() async{
    conversation = null;
  }

  @override
  ChatwootConversation? getConversation(){
    return conversation;
  }

  @override
  void onDispose() {
    conversation = null;
  }

  @override
  Future<void> saveConversation(ChatwootConversation conversation) async{
    conversation = conversation;
  }


}
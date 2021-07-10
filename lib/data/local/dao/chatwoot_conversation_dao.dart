
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';


abstract class ChatwootConversationDao{
  Future<void> openDB();
  Future<void> saveConversation(ChatwootConversation conversation);
  ChatwootConversation? getConversation();
  Future<void> deleteConversation();
  void onDispose();
}

//Only used when persistence is enabled
enum ChatwootConversationBoxNames{
  CONVERSATIONS, CLIENT_INSTANCE_TO_CONVERSATIONS
}
class PersistedChatwootConversationDao extends ChatwootConversationDao{
  
  
  //box containing all persisted conversations
  Box<ChatwootConversation> box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> clientInstanceIdToConversationIdentifierBox;

  final String clientInstanceKey;

  PersistedChatwootConversationDao(
    this.box,
    this.clientInstanceIdToConversationIdentifierBox,{
    required this.clientInstanceKey
  });
  
  @override
  Future<void> deleteConversation() async{
    final conversationIdentifier = clientInstanceIdToConversationIdentifierBox.get(
        clientInstanceKey
    );
    await clientInstanceIdToConversationIdentifierBox.delete(
        clientInstanceKey
    );
    await box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(ChatwootConversation conversation) async{
    await clientInstanceIdToConversationIdentifierBox.put(
        clientInstanceKey, 
        conversation.id.toString()
    );
    await box.put(conversation.id, conversation);
  }

  @override
  ChatwootConversation? getConversation() {
    if(box.values.length==0){
      return null;
    }
    
    final conversationidentifierString = clientInstanceIdToConversationIdentifierBox.get(
        clientInstanceKey
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

  @override
  Future<void> openDB() async{
    ChatwootConversationBoxNames.values.forEach((boxName) async{
      await Hive.openBox(boxName.toString());
    });
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

  @override
  Future<void> openDB() async{
    //nothing to do here
  }


}
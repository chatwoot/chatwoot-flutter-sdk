
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ChatwootUserDao{
  Future<void> saveUser(ChatwootUser user);
  ChatwootUser? getUser();
  Future<void> deleteUser();
  void onDispose();
}

class PersistedChatwootUserDao extends ChatwootUserDao{
  //box containing chat users
  Box<ChatwootUser> box;
  //box with one to one relation between generated client instance id and user identifier
  final Box<String> generatedClientInstanceIdToUserIdentifierBox;
  String baseUrl;
  String inboxIdentifier;
  String? userIdentifier;

  PersistedChatwootUserDao(
      this.box,
      this.generatedClientInstanceIdToUserIdentifierBox,{
        required this.baseUrl,
        required this.inboxIdentifier,
        this.userIdentifier
  });

  final keySeparator= "|||";

  String getUserGeneratedClientInstanceKey(){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier${keySeparator}user";
  }

  @override
  Future<void> deleteUser() async{
    final userIdentifier = generatedClientInstanceIdToUserIdentifierBox.get(
        getUserGeneratedClientInstanceKey()
    );
    await generatedClientInstanceIdToUserIdentifierBox.delete(
        getUserGeneratedClientInstanceKey()
    );
    await box.delete(userIdentifier);
  }

  @override
  Future<void> saveUser(ChatwootUser user) async{
    await generatedClientInstanceIdToUserIdentifierBox.put(
        getUserGeneratedClientInstanceKey(),
        user.identifier.toString()
    );
    await box.put(user.identifier, user);
  }

  @override
  ChatwootUser? getUser(){
    if(box.values.length==0){
      return null;
    }
    final userIdentifier = generatedClientInstanceIdToUserIdentifierBox.get(
        getUserGeneratedClientInstanceKey()
    );

    return box.get(userIdentifier);
  }

  @override
  void onDispose() {
    box.close();
  }

}

class NonPersistedChatwootUserDao extends ChatwootUserDao{
  ChatwootUser? user;

  @override
  Future<void> deleteUser() async{
    user = null;
  }

  @override
  ChatwootUser? getUser() {
    return user;
  }

  @override
  void onDispose() {
    user = null;
  }

  @override
  Future<void> saveUser(ChatwootUser user) async{
    user = user;
  }


}
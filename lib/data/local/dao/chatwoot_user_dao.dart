
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ChatwootUserDao{

  Future<void> openDB();
  Future<void> saveUser(ChatwootUser user);
  ChatwootUser? getUser();
  Future<void> deleteUser();
  void onDispose();
}


//Only used when persistence is enabled
enum ChatwootUserBoxNames{
  USERS, CLIENT_INSTANCE_TO_USER
}
class PersistedChatwootUserDao extends ChatwootUserDao{
  //box containing chat users
  Box<ChatwootUser> box;
  //box with one to one relation between generated client instance id and user identifier
  final Box<String> clientInstanceIdToUserIdentifierBox;

  final String clientInstanceKey;

  PersistedChatwootUserDao(
      this.box,
      this.clientInstanceIdToUserIdentifierBox,{
      required this.clientInstanceKey
  });

  @override
  Future<void> deleteUser() async{
    final userIdentifier = clientInstanceIdToUserIdentifierBox.get(
        clientInstanceKey
    );
    await clientInstanceIdToUserIdentifierBox.delete(
        clientInstanceKey
    );
    await box.delete(userIdentifier);
  }

  @override
  Future<void> saveUser(ChatwootUser user) async{
    await clientInstanceIdToUserIdentifierBox.put(
        clientInstanceKey,
        user.identifier.toString()
    );
    await box.put(user.identifier, user);
  }

  @override
  ChatwootUser? getUser(){
    if(box.values.length==0){
      return null;
    }
    final userIdentifier = clientInstanceIdToUserIdentifierBox.get(
        clientInstanceKey
    );

    return box.get(userIdentifier);
  }

  @override
  void onDispose() {
    box.close();
  }

  @override
  Future<void> openDB() async{
    ChatwootUserBoxNames.values.forEach((boxName) async{
      await Hive.openBox(boxName.toString());
    });
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

  @override
  Future<void> openDB() async{
    //nothing to do here
  }


}
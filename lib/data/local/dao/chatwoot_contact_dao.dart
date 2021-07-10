
import 'package:hive_flutter/hive_flutter.dart';

import '../entity/chatwoot_contact.dart';

abstract class ChatwootContactDao{
  Future<void> openDB();
  Future<void> saveContact(ChatwootContact contact);
  ChatwootContact? getContact();
  Future<void> deleteContact();
  void onDispose();
}

//Only used when persistence is enabled
enum ChatwootContactBoxNames{
  CONTACTS, CLIENT_INSTANCE_TO_CONTACTS
}
class PersistedChatwootContactDao extends ChatwootContactDao{
  
  //box containing all persisted contacts
  Box<ChatwootContact> box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> clientInstanceIdToContactIdentifierBox;

  final String clientInstanceKey;

  PersistedChatwootContactDao(
    this.box,
    this.clientInstanceIdToContactIdentifierBox,{
    required this.clientInstanceKey
  });

  @override
  Future<void> deleteContact() async{
    final contactIdentifier = clientInstanceIdToContactIdentifierBox.get(
        clientInstanceKey
    );
    await clientInstanceIdToContactIdentifierBox.delete(
        clientInstanceKey
    );
    await box.delete(contactIdentifier);
  }

  @override
  Future<void> saveContact(ChatwootContact contact) async{
    await clientInstanceIdToContactIdentifierBox.put(
        clientInstanceKey,
        contact.contactIdentifier
    );
    await box.put(contact.contactIdentifier, contact);
  }

  @override
  ChatwootContact? getContact(){
    if(box.values.length==0){
      return null;
    }

    final contactIdentifier = clientInstanceIdToContactIdentifierBox.get(
        clientInstanceKey
    );

    return box.get(contactIdentifier,defaultValue: null);
  }

  @override
  void onDispose() {
    box.close();
  }

  @override
  Future<void> openDB() async{
    ChatwootContactBoxNames.values.forEach((value) async{
      await Hive.openBox(value.toString());
    });
  }

}

class NonPersistedChatwootContactDao extends ChatwootContactDao{
  ChatwootContact? contact;


  @override
  Future<void> deleteContact() async{
    contact = null;
  }

  @override
  ChatwootContact? getContact() {
    return contact;
  }

  @override
  void onDispose() {
    contact = null;
  }

  @override
  Future<void> saveContact(ChatwootContact contact) async{
    contact = contact;
  }

  @override
  Future<void> openDB() async{
    //nothing to do here
  }


}
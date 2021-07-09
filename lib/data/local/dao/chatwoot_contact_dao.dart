
import 'package:hive_flutter/hive_flutter.dart';

import '../entity/chatwoot_contact.dart';

abstract class ChatwootContactDao{
  Future<void> saveContact(ChatwootContact contact);
  ChatwootContact? getContact();
  Future<void> deleteContact();
  void onDispose();
}

class PersistedChatwootContactDao extends ChatwootContactDao{
  //box containing all persisted contacts
  Box<ChatwootContact> box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> generatedClientInstanceIdToContactIdentifierBox;
  String baseUrl;
  String inboxIdentifier;
  String? userIdentifier;

  PersistedChatwootContactDao(
    this.box,
    this.generatedClientInstanceIdToContactIdentifierBox,{
    required this.baseUrl,
    required this.inboxIdentifier,
    this.userIdentifier
  });

  final keySeparator= "|||";

  String getContactGeneratedClientInstanceKey(){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier${keySeparator}contact";
  }

  @override
  Future<void> deleteContact() async{
    final contactIdentifier = generatedClientInstanceIdToContactIdentifierBox.get(
        getContactGeneratedClientInstanceKey()
    );
    await generatedClientInstanceIdToContactIdentifierBox.delete(
        getContactGeneratedClientInstanceKey()
    );
    await box.delete(contactIdentifier);
  }

  @override
  Future<void> saveContact(ChatwootContact contact) async{
    await generatedClientInstanceIdToContactIdentifierBox.put(
        getContactGeneratedClientInstanceKey(),
        contact.contactIdentifier
    );
    await box.put(contact.contactIdentifier, contact);
  }

  @override
  ChatwootContact? getContact(){
    if(box.values.length==0){
      return null;
    }

    final contactIdentifier = generatedClientInstanceIdToContactIdentifierBox.get(
        getContactGeneratedClientInstanceKey()
    );

    return box.get(contactIdentifier,defaultValue: null);
  }

  @override
  void onDispose() {
    box.close();
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


}
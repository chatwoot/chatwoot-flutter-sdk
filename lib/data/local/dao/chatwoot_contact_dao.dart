import 'package:hive_flutter/hive_flutter.dart';

import '../entity/chatwoot_contact.dart';

///Data access object for retriving chatwoot contact from local storage
abstract class ChatwootContactDao {
  Future<void> saveContact(ChatwootContact contact);
  ChatwootContact? getContact();
  Future<void> deleteContact();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum ChatwootContactBoxNames { CONTACTS, CLIENT_INSTANCE_TO_CONTACTS }

class PersistedChatwootContactDao extends ChatwootContactDao {
  //box containing all persisted contacts
  Box<ChatwootContact> _box;

  //_box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToContactIdentifierBox;

  final String _clientInstanceKey;

  PersistedChatwootContactDao(this._box,
      this._clientInstanceIdToContactIdentifierBox, this._clientInstanceKey);

  @override
  Future<void> deleteContact() async {
    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToContactIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(contactIdentifier);
  }

  @override
  Future<void> saveContact(ChatwootContact contact) async {
    await _clientInstanceIdToContactIdentifierBox.put(
        _clientInstanceKey, contact.contactIdentifier!);
    await _box.put(contact.contactIdentifier, contact);
  }

  @override
  ChatwootContact? getContact() {
    if (_box.values.length == 0) {
      return null;
    }

    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);

    if (contactIdentifier == null) {
      return null;
    }

    return _box.get(contactIdentifier, defaultValue: null);
  }

  @override
  Future<void> onDispose() async {}

  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToContactIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<ChatwootContact>(
        ChatwootContactBoxNames.CONTACTS.toString());
    await Hive.openBox<String>(
        ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
  }
}

class NonPersistedChatwootContactDao extends ChatwootContactDao {
  ChatwootContact? _contact;

  @override
  Future<void> deleteContact() async {
    _contact = null;
  }

  @override
  ChatwootContact? getContact() {
    return _contact;
  }

  @override
  Future<void> onDispose() async {
    _contact = null;
  }

  @override
  Future<void> saveContact(ChatwootContact contact) async {
    _contact = contact;
  }

  Future<void> clearAll() async {
    _contact = null;
  }
}

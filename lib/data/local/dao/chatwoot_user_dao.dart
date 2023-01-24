import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ChatwootUserDao {
  Future<void> saveUser(ChatwootUser user);
  ChatwootUser? getUser();
  Future<void> deleteUser();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum ChatwootUserBoxNames { USERS, CLIENT_INSTANCE_TO_USER }

class PersistedChatwootUserDao extends ChatwootUserDao {
  //box containing chat users
  Box<ChatwootUser> _box;
  //box with one to one relation between generated client instance id and user identifier
  final Box<String> _clientInstanceIdToUserIdentifierBox;

  final String _clientInstanceKey;

  PersistedChatwootUserDao(this._box, this._clientInstanceIdToUserIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteUser() async {
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToUserIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(userIdentifier);
  }

  @override
  Future<void> saveUser(ChatwootUser user) async {
    await _clientInstanceIdToUserIdentifierBox.put(
        _clientInstanceKey, user.identifier.toString());
    await _box.put(user.identifier, user);
  }

  @override
  ChatwootUser? getUser() {
    if (_box.values.length == 0) {
      return null;
    }
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);

    return _box.get(userIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToUserIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<ChatwootUser>(ChatwootUserBoxNames.USERS.toString());
    await Hive.openBox<String>(
        ChatwootUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
  }
}

class NonPersistedChatwootUserDao extends ChatwootUserDao {
  ChatwootUser? _user;

  @override
  Future<void> deleteUser() async {
    _user = null;
  }

  @override
  ChatwootUser? getUser() {
    return _user;
  }

  @override
  Future<void> onDispose() async {
    _user = null;
  }

  @override
  Future<void> saveUser(ChatwootUser user) async {
    _user = user;
  }

  @override
  Future<void> clearAll() async {
    _user = null;
  }
}

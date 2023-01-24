import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ChatwootConversationDao {
  Future<void> saveConversation(ChatwootConversation conversation);
  ChatwootConversation? getConversation();
  Future<void> deleteConversation();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum ChatwootConversationBoxNames {
  CONVERSATIONS,
  CLIENT_INSTANCE_TO_CONVERSATIONS
}

class PersistedChatwootConversationDao extends ChatwootConversationDao {
  //box containing all persisted conversations
  Box<ChatwootConversation> _box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToConversationIdentifierBox;

  final String _clientInstanceKey;

  PersistedChatwootConversationDao(
      this._box,
      this._clientInstanceIdToConversationIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteConversation() async {
    final conversationIdentifier =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToConversationIdentifierBox
        .delete(_clientInstanceKey);
    await _box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(ChatwootConversation conversation) async {
    await _clientInstanceIdToConversationIdentifierBox.put(
        _clientInstanceKey, conversation.id.toString());
    await _box.put(conversation.id, conversation);
  }

  @override
  ChatwootConversation? getConversation() {
    if (_box.values.length == 0) {
      return null;
    }

    final conversationidentifierString =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    final conversationIdentifier =
        int.tryParse(conversationidentifierString ?? "");

    if (conversationIdentifier == null) {
      return null;
    }

    return _box.get(conversationIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  static Future<void> openDB() async {
    await Hive.openBox<ChatwootConversation>(
        ChatwootConversationBoxNames.CONVERSATIONS.toString());
    await Hive.openBox<String>(ChatwootConversationBoxNames
        .CLIENT_INSTANCE_TO_CONVERSATIONS
        .toString());
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToConversationIdentifierBox.clear();
  }
}

class NonPersistedChatwootConversationDao extends ChatwootConversationDao {
  ChatwootConversation? _conversation;

  @override
  Future<void> deleteConversation() async {
    _conversation = null;
  }

  @override
  ChatwootConversation? getConversation() {
    return _conversation;
  }

  @override
  Future<void> onDispose() async {
    _conversation = null;
  }

  @override
  Future<void> saveConversation(ChatwootConversation conversation) async {
    _conversation = conversation;
  }

  @override
  Future<void> clearAll() async {
    _conversation = null;
  }
}

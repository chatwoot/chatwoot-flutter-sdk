// Synthetic upgrade fixture: legacy Hive 2.2.3 uses the retained wire schema.
// These adapters intentionally use the old engine, not Hive CE's writer.
import 'package:hive/hive.dart' as legacy;
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';

class LegacyChatwootContactAdapter extends legacy.TypeAdapter<ChatwootContact> {
  @override
  final typeId = 0;

  @override
  ChatwootContact read(legacy.BinaryReader reader) =>
      throw UnimplementedError();

  @override
  void write(legacy.BinaryWriter writer, ChatwootContact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactIdentifier)
      ..writeByte(2)
      ..write(obj.pubsubToken)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email);
  }
}

class LegacyChatwootConversationAdapter
    extends legacy.TypeAdapter<ChatwootConversation> {
  @override
  final typeId = 1;

  @override
  ChatwootConversation read(legacy.BinaryReader reader) =>
      throw UnimplementedError();

  @override
  void write(legacy.BinaryWriter writer, ChatwootConversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inboxId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.contact);
  }
}

class LegacyChatwootMessageAdapter extends legacy.TypeAdapter<ChatwootMessage> {
  @override
  final typeId = 2;

  @override
  ChatwootMessage read(legacy.BinaryReader reader) =>
      throw UnimplementedError();

  @override
  void write(legacy.BinaryWriter writer, ChatwootMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.messageType)
      ..writeByte(3)
      ..write(obj.contentType)
      ..writeByte(4)
      ..write(obj.contentAttributes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.conversationId)
      ..writeByte(7)
      ..write(obj.attachments)
      ..writeByte(8)
      ..write(obj.sender);
  }
}

class LegacyChatwootUserAdapter extends legacy.TypeAdapter<ChatwootUser> {
  @override
  final typeId = 3;

  @override
  ChatwootUser read(legacy.BinaryReader reader) => throw UnimplementedError();

  @override
  void write(legacy.BinaryWriter writer, ChatwootUser obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.identifierHash)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.customAttributes);
  }
}

class LegacyChatwootEventMessageUserAdapter
    extends legacy.TypeAdapter<ChatwootEventMessageUser> {
  @override
  final typeId = 4;

  @override
  ChatwootEventMessageUser read(legacy.BinaryReader reader) =>
      throw UnimplementedError();

  @override
  void write(legacy.BinaryWriter writer, ChatwootEventMessageUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.avatarUrl)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.thumbnail);
  }
}

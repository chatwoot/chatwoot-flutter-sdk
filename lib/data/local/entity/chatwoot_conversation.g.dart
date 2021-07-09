// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatwootConversationAdapter extends TypeAdapter<ChatwootConversation> {
  @override
  final int typeId = 1;

  @override
  ChatwootConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatwootConversation(
      id: fields[0] as int,
      inboxId: fields[1] as String,
      messages: fields[2] as String,
      contact: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatwootConversation obj) {
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatwootConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootConversation _$ChatwootConversationFromJson(Map<String, dynamic> json) {
  return ChatwootConversation(
    id: json['id'] as int,
    inboxId: json['inbox_id'] as String,
    messages: json['messages'] as String,
    contact: json['contact'] as String,
  );
}

Map<String, dynamic> _$ChatwootConversationToJson(
        ChatwootConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inbox_id': instance.inboxId,
      'messages': instance.messages,
      'contact': instance.contact,
    };

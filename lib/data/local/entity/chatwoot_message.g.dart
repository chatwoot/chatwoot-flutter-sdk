// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatwootMessageAdapter extends TypeAdapter<ChatwootMessage> {
  @override
  final int typeId = 2;

  @override
  ChatwootMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatwootMessage(
      id: fields[0] as String,
      content: fields[1] as String,
      messageType: fields[2] as String,
      contentType: fields[3] as String,
      contentAttributes: fields[4] as String,
      createdAt: fields[5] as String,
      conversationId: fields[6] as String,
      attachments: (fields[7] as List).cast<dynamic>(),
      sender: fields[8] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ChatwootMessage obj) {
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatwootMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootMessage _$ChatwootMessageFromJson(Map<String, dynamic> json) {
  return ChatwootMessage(
    id: json['id'] as String,
    content: json['content'] as String,
    messageType: json['message_type'] as String,
    contentType: json['content_type'] as String,
    contentAttributes: json['content_attributes'] as String,
    createdAt: json['created_at'] as String,
    conversationId: json['conversation_id'] as String,
    attachments: json['attachments'] as List<dynamic>,
    sender: json['sender'],
  );
}

Map<String, dynamic> _$ChatwootMessageToJson(ChatwootMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'message_type': instance.messageType,
      'content_type': instance.contentType,
      'content_attributes': instance.contentAttributes,
      'created_at': instance.createdAt,
      'conversation_id': instance.conversationId,
      'attachments': instance.attachments,
      'sender': instance.sender,
    };

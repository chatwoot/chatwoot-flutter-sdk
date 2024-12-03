// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatwootMessageAdapter extends TypeAdapter<ChatwootMessage> {
  @override
  final int typeId = 112;

  @override
  ChatwootMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatwootMessage(
      id: fields[0] as int,
      content: fields[1] as String?,
      messageType: fields[2] as int?,
      contentType: fields[3] as String?,
      contentAttributes: fields[4] as dynamic,
      createdAt: fields[5] as String,
      conversationId: fields[6] as int?,
      attachments: (fields[7] as List?)?.cast<ChatwootMessageAttachment>(),
      sender: fields[8] as ChatwootEventMessageUser?,
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

class ChatwootMessageAttachmentAdapter
    extends TypeAdapter<ChatwootMessageAttachment> {
  @override
  final int typeId = 115;

  @override
  ChatwootMessageAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatwootMessageAttachment(
      id: fields[1] as int?,
      messageId: fields[2] as int?,
      fileType: fields[3] as String?,
      accountId: fields[4] as int?,
      dataUrl: fields[5] as String?,
      thumbUrl: fields[6] as String?,
      fileSize: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatwootMessageAttachment obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.messageId)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.accountId)
      ..writeByte(5)
      ..write(obj.dataUrl)
      ..writeByte(6)
      ..write(obj.thumbUrl)
      ..writeByte(7)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatwootMessageAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootMessage _$ChatwootMessageFromJson(Map<String, dynamic> json) =>
    ChatwootMessage(
      id: idFromJson(json['id']),
      content: json['content'] as String?,
      messageType: messageTypeFromJson(json['message_type']),
      contentType: json['content_type'] as String?,
      contentAttributes: json['content_attributes'],
      createdAt: createdAtFromJson(json['created_at']),
      conversationId: idFromJson(json['conversation_id']),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) =>
              ChatwootMessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      sender: json['sender'] == null
          ? null
          : ChatwootEventMessageUser.fromJson(
              json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatwootMessageToJson(ChatwootMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'message_type': instance.messageType,
      'content_type': instance.contentType,
      'content_attributes': instance.contentAttributes,
      'created_at': instance.createdAt,
      'conversation_id': instance.conversationId,
      'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
      'sender': instance.sender?.toJson(),
    };

ChatwootMessageAttachment _$ChatwootMessageAttachmentFromJson(
        Map<String, dynamic> json) =>
    ChatwootMessageAttachment(
      id: (json['id'] as num?)?.toInt(),
      messageId: (json['message_id'] as num?)?.toInt(),
      fileType: json['file_type'] as String?,
      accountId: (json['account_id'] as num?)?.toInt(),
      dataUrl: json['data_url'] as String?,
      thumbUrl: json['thumb_url'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatwootMessageAttachmentToJson(
        ChatwootMessageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_id': instance.messageId,
      'file_type': instance.fileType,
      'account_id': instance.accountId,
      'data_url': instance.dataUrl,
      'thumb_url': instance.thumbUrl,
      'file_size': instance.fileSize,
    };

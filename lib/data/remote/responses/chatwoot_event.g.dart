// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatwootEventMessageUserAdapter
    extends TypeAdapter<ChatwootEventMessageUser> {
  @override
  final int typeId = 114;

  @override
  ChatwootEventMessageUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatwootEventMessageUser(
      id: fields[1] as int?,
      avatarUrl: fields[0] as String?,
      name: fields[2] as String?,
      thumbnail: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatwootEventMessageUser obj) {
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatwootEventMessageUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootEvent _$ChatwootEventFromJson(Map<String, dynamic> json) =>
    ChatwootEvent(
      type: eventTypeFromJson(json['type'] as String?),
      message: eventMessageFromJson(json['message']),
      identifier: json['identifier'] as String?,
    );

Map<String, dynamic> _$ChatwootEventToJson(ChatwootEvent instance) =>
    <String, dynamic>{
      'type': eventTypeToJson(instance.type),
      'identifier': instance.identifier,
      'message': instance.message?.toJson(),
    };

ChatwootEventMessage _$ChatwootEventMessageFromJson(
        Map<String, dynamic> json) =>
    ChatwootEventMessage(
      data: json['data'] == null
          ? null
          : ChatwootEventMessageData.fromJson(
              json['data'] as Map<String, dynamic>),
      event: eventMessageTypeFromJson(json['event'] as String?),
    );

Map<String, dynamic> _$ChatwootEventMessageToJson(
        ChatwootEventMessage instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
      'event': eventMessageTypeToJson(instance.event),
    };

ChatwootEventMessageData _$ChatwootEventMessageDataFromJson(
        Map<String, dynamic> json) =>
    ChatwootEventMessageData(
      id: (json['id'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : ChatwootEventMessageUser.fromJson(
              json['user'] as Map<String, dynamic>),
      conversation: json['conversation'],
      echoId: json['echo_id'] as String?,
      sender: json['sender'] == null
          ? null
          : ChatwootEventMessageUser.fromJson(
              json['sender'] as Map<String, dynamic>),
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      createdAt: json['created_at'],
      contentAttributes: json['content_attributes'],
      contentType: json['content_type'] as String?,
      messageType: (json['message_type'] as num?)?.toInt(),
      content: json['content'] as String?,
      inboxId: (json['inbox_id'] as num?)?.toInt(),
      sourceId: json['source_id'] as String?,
      updatedAt: json['updated_at'],
      status: json['status'] as String?,
      accountId: (json['account_id'] as num?)?.toInt(),
      externalSourceIds: json['external_source_ids'],
      private: json['private'] as bool?,
      senderId: (json['sender_id'] as num?)?.toInt(),
      users: json['users'],
    );

Map<String, dynamic> _$ChatwootEventMessageDataToJson(
        ChatwootEventMessageData instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'content': instance.content,
      'content_attributes': instance.contentAttributes,
      'content_type': instance.contentType,
      'conversation_id': instance.conversationId,
      'created_at': instance.createdAt,
      'echo_id': instance.echoId,
      'external_source_ids': instance.externalSourceIds,
      'id': instance.id,
      'inbox_id': instance.inboxId,
      'message_type': instance.messageType,
      'private': instance.private,
      'sender': instance.sender?.toJson(),
      'sender_id': instance.senderId,
      'source_id': instance.sourceId,
      'status': instance.status,
      'updated_at': instance.updatedAt,
      'conversation': instance.conversation,
      'user': instance.user?.toJson(),
      'users': instance.users,
    };

ChatwootEventMessageUser _$ChatwootEventMessageUserFromJson(
        Map<String, dynamic> json) =>
    ChatwootEventMessageUser(
      id: (json['id'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
      name: json['name'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$ChatwootEventMessageUserToJson(
        ChatwootEventMessageUser instance) =>
    <String, dynamic>{
      'avatar_url': instance.avatarUrl,
      'id': instance.id,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
    };

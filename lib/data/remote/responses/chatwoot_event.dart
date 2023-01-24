import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:chatwoot_sdk/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_event.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatwootEvent {
  @JsonKey(toJson: eventTypeToJson, fromJson: eventTypeFromJson)
  final ChatwootEventType? type;

  @JsonKey()
  final String? identifier;

  @JsonKey(fromJson: eventMessageFromJson)
  final ChatwootEventMessage? message;

  ChatwootEvent({this.type, this.message, this.identifier});

  factory ChatwootEvent.fromJson(Map<String, dynamic> json) =>
      _$ChatwootEventFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventToJson(this);
}

ChatwootEventMessage? eventMessageFromJson(value) {
  if (value == null) {
    return null;
  } else if (value is num) {
    return ChatwootEventMessage();
  } else if (value is String) {
    return ChatwootEventMessage();
  } else {
    return ChatwootEventMessage.fromJson(value as Map<String, dynamic>);
  }
}

@JsonSerializable(explicitToJson: true)
class ChatwootEventMessage {
  @JsonKey()
  final ChatwootEventMessageData? data;

  @JsonKey(toJson: eventMessageTypeToJson, fromJson: eventMessageTypeFromJson)
  final ChatwootEventMessageType? event;

  ChatwootEventMessage({this.data, this.event});

  factory ChatwootEventMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatwootEventMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChatwootEventMessageData {
  @JsonKey(name: "account_id")
  final int? accountId;

  @JsonKey()
  final String? content;

  @JsonKey(name: "content_attributes")
  final dynamic contentAttributes;

  @JsonKey(name: "content_type")
  final String? contentType;

  @JsonKey(name: "conversation_id")
  final int? conversationId;

  @JsonKey(name: "created_at")
  final dynamic createdAt;

  @JsonKey(name: "echo_id")
  final String? echoId;

  @JsonKey(name: "external_source_ids")
  final dynamic externalSourceIds;

  @JsonKey()
  final int? id;

  @JsonKey(name: "inbox_id")
  final int? inboxId;

  @JsonKey(name: "message_type")
  final int? messageType;

  @JsonKey(name: "private")
  final bool? private;

  @JsonKey()
  final ChatwootEventMessageUser? sender;

  @JsonKey(name: "sender_id")
  final int? senderId;

  @JsonKey(name: "source_id")
  final String? sourceId;

  @JsonKey()
  final String? status;

  @JsonKey(name: "updated_at")
  final dynamic updatedAt;

  @JsonKey()
  final dynamic conversation;

  @JsonKey()
  final ChatwootEventMessageUser? user;

  @JsonKey()
  final dynamic users;

  ChatwootEventMessageData(
      {this.id,
      this.user,
      this.conversation,
      this.echoId,
      this.sender,
      this.conversationId,
      this.createdAt,
      this.contentAttributes,
      this.contentType,
      this.messageType,
      this.content,
      this.inboxId,
      this.sourceId,
      this.updatedAt,
      this.status,
      this.accountId,
      this.externalSourceIds,
      this.private,
      this.senderId,
      this.users});

  factory ChatwootEventMessageData.fromJson(Map<String, dynamic> json) =>
      _$ChatwootEventMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageDataToJson(this);

  getMessage() {
    return ChatwootMessage.fromJson(toJson());
  }
}

/// {@category FlutterClientSdk}
@HiveType(typeId: CHATWOOT_EVENT_USER_HIVE_TYPE_ID)
@JsonSerializable(explicitToJson: true)
class ChatwootEventMessageUser extends Equatable {
  @JsonKey(name: "avatar_url")
  @HiveField(0)
  final String? avatarUrl;

  @JsonKey()
  @HiveField(1)
  final int? id;

  @JsonKey()
  @HiveField(2)
  final String? name;

  @JsonKey()
  @HiveField(3)
  final String? thumbnail;

  ChatwootEventMessageUser(
      {this.id, this.avatarUrl, this.name, this.thumbnail});

  factory ChatwootEventMessageUser.fromJson(Map<String, dynamic> json) =>
      _$ChatwootEventMessageUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageUserToJson(this);

  @override
  List<Object?> get props => [id, avatarUrl, name, thumbnail];
}

enum ChatwootEventType { welcome, ping, confirm_subscription }

String? eventTypeToJson(ChatwootEventType? actionType) {
  return actionType.toString();
}

ChatwootEventType? eventTypeFromJson(String? value) {
  switch (value) {
    case "welcome":
      return ChatwootEventType.welcome;
    case "ping":
      return ChatwootEventType.ping;
    case "confirm_subscription":
      return ChatwootEventType.confirm_subscription;
    default:
      return null;
  }
}

enum ChatwootEventMessageType {
  presence_update,
  message_created,
  message_updated,
  conversation_typing_off,
  conversation_typing_on,
  conversation_status_changed
}

String? eventMessageTypeToJson(ChatwootEventMessageType? actionType) {
  switch (actionType) {
    case null:
      return null;
    case ChatwootEventMessageType.conversation_typing_on:
      return "conversation.typing_on";
    case ChatwootEventMessageType.conversation_typing_off:
      return "conversation.typing_off";
    case ChatwootEventMessageType.presence_update:
      return "presence.update";
    case ChatwootEventMessageType.message_created:
      return "message.created";
    case ChatwootEventMessageType.message_updated:
      return "message.updated";
    case ChatwootEventMessageType.conversation_status_changed:
      return "conversation.status_changed";
    default:
      return actionType.toString();
  }
}

ChatwootEventMessageType? eventMessageTypeFromJson(String? value) {
  switch (value) {
    case "presence.update":
      return ChatwootEventMessageType.presence_update;
    case "message.created":
      return ChatwootEventMessageType.message_created;
    case "message.updated":
      return ChatwootEventMessageType.message_updated;
    case "conversation.typing_on":
      return ChatwootEventMessageType.conversation_typing_on;
    case "conversation.typing_off":
      return ChatwootEventMessageType.conversation_typing_off;
    case "conversation.status_changed":
      return ChatwootEventMessageType.conversation_status_changed;
    default:
      return null;
  }
}



import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_event.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatwootEvent{

  @JsonKey(
    toJson: eventTypeToJson,
    fromJson: eventTypeFromJson
  )
  final ChatwootEventType? type;

  @JsonKey()
  final String? identifier;

  @JsonKey()
  final ChatwootEventMessage? message;

  ChatwootEvent({
    this.type,
    this.message,
    this.identifier
  });

  factory ChatwootEvent.fromJson(Map<String, dynamic> json) => _$ChatwootEventFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventToJson(this);

}

@JsonSerializable(explicitToJson: true)
class ChatwootEventMessage{

  @JsonKey()
  final ChatwootEventMessageData? data;

  @JsonKey(
    toJson: eventMessageTypeToJson,
    fromJson: eventMessageTypeFromJson
  )
  final ChatwootEventMessageType? event;

  ChatwootEventMessage({
    this.data,
    this.event
  });

  factory ChatwootEventMessage.fromJson(Map<String, dynamic> json) => _$ChatwootEventMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChatwootEventMessageData{

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
  final int? private;

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

  ChatwootEventMessageData({
    this.id,
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
    this.senderId
  });


  factory ChatwootEventMessageData.fromJson(Map<String, dynamic> json) => _$ChatwootEventMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageDataToJson(this);

  getMessage(){
    return ChatwootMessage.fromJson(toJson());
  }
}

@JsonSerializable(explicitToJson: true)
class ChatwootEventMessageUser{

  @JsonKey()
  final String? type;

  @JsonKey(name: "availability_status")
  final String? availabilityStatus;

  @JsonKey(name: "available_name")
  final String? availableName;

  @JsonKey(name: "avatar_url")
  final String? avatarUrl;

  @JsonKey()
  final int? id;

  @JsonKey()
  final String? name;


  ChatwootEventMessageUser({
    this.id,
    this.type,
    this.avatarUrl,
    this.name,
    this.availabilityStatus,
    this.availableName
  });


  factory ChatwootEventMessageUser.fromJson(Map<String, dynamic> json) => _$ChatwootEventMessageUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootEventMessageUserToJson(this);

}

enum ChatwootEventType{
  welcome,
  ping,
  confirm_subscription
}

String? eventTypeToJson(ChatwootEventType? actionType){
  return actionType.toString();
}

ChatwootEventType? eventTypeFromJson(String? value){
  switch(value){
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

enum ChatwootEventMessageType{
  presence_update,
  message_created,
  conversation_typing_off,
  conversation_typing_on
}

String? eventMessageTypeToJson(ChatwootEventMessageType? actionType){
  switch(actionType){
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
    default:
      return actionType.toString();
  }
}

ChatwootEventMessageType? eventMessageTypeFromJson(String? value){
  switch(value){
    case "presence.update":
      return ChatwootEventMessageType.presence_update;
    case "message.created":
      return ChatwootEventMessageType.message_created;
    case "conversation.typing_on":
      return ChatwootEventMessageType.conversation_typing_on;
    case "conversation.typing_off":
      return ChatwootEventMessageType.conversation_typing_off;
    default:
      return null;
  }
}
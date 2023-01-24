import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'chatwoot_message.g.dart';

/// {@category FlutterClientSdk}
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: CHATWOOT_MESSAGE_HIVE_TYPE_ID)
class ChatwootMessage extends Equatable {
  ///unique identifier of the message
  @JsonKey(fromJson: idFromJson)
  @HiveField(0)
  final int id;

  ///text content of the message
  @JsonKey()
  @HiveField(1)
  final String? content;

  ///type of message
  ///
  ///returns 1 if message belongs to contact making the request
  @JsonKey(name: "message_type", fromJson: messageTypeFromJson)
  @HiveField(2)
  final int? messageType;

  ///content type of message
  @JsonKey(name: "content_type")
  @HiveField(3)
  final String? contentType;

  @JsonKey(name: "content_attributes")
  @HiveField(4)
  final dynamic contentAttributes;

  ///date and time message was created
  @JsonKey(name: "created_at", fromJson: createdAtFromJson)
  @HiveField(5)
  final String createdAt;

  ///id of the conversation the message belongs to
  @JsonKey(name: "conversation_id", fromJson: idFromJson)
  @HiveField(6)
  final int? conversationId;

  ///list of media/doc/file attachment for message
  @JsonKey()
  @HiveField(7)
  final List<dynamic>? attachments;

  ///The user this message belongs to
  @JsonKey(name: "sender")
  @HiveField(8)
  final ChatwootEventMessageUser? sender;

  ///checks if message belongs to contact making the request
  bool get isMine => messageType != 1;

  ChatwootMessage(
      {required this.id,
      required this.content,
      required this.messageType,
      required this.contentType,
      required this.contentAttributes,
      required this.createdAt,
      required this.conversationId,
      required this.attachments,
      required this.sender});

  factory ChatwootMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatwootMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootMessageToJson(this);

  @override
  List<Object?> get props => [
        id,
        content,
        messageType,
        contentType,
        contentAttributes,
        createdAt,
        conversationId,
        attachments,
        sender
      ];
}

int idFromJson(value) {
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return value;
}

int messageTypeFromJson(value) {
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return value;
}

String createdAtFromJson(value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000).toString();
  }
  return value.toString();
}

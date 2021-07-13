
import 'package:chatwoot_client_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_message.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 2)
class ChatwootMessage extends Equatable{

  @JsonKey(
    fromJson: idFromJson
  )
  @HiveField(0)
  final int id;

  @JsonKey()
  @HiveField(1)
  final String? content;

  @JsonKey(
      name:"message_type",
    fromJson: messageTypeFromJson
  )
  @HiveField(2)
  final int? messageType;

  @JsonKey(name:"content_type")
  @HiveField(3)
  final String? contentType;

  @JsonKey(name:"content_attributes")
  @HiveField(4)
  final dynamic contentAttributes;

  @JsonKey(
    name:"created_at",
    fromJson: createdAtFromJson
  )
  @HiveField(5)
  final String createdAt;

  @JsonKey(
    name:"conversation_id",
    fromJson: idFromJson
  )
  @HiveField(6)
  final int? conversationId;

  @JsonKey()
  @HiveField(7)
  final List<dynamic>? attachments;

  @JsonKey(name:"sender")
  @HiveField(8)
  final ChatwootEventMessageUser? sender;

  bool get isMine => messageType != 1;

  ChatwootMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.contentType,
    required this.contentAttributes,
    required this.createdAt,
    required this.conversationId,
    required this.attachments,
    required this.sender
  });


  factory ChatwootMessage.fromJson(Map<String, dynamic> json) => _$ChatwootMessageFromJson(json);

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

int idFromJson(value){
  if(value is String){
    return int.tryParse(value) ?? 0;
  }
  return value;
}

int messageTypeFromJson(value){
  if(value is String){
    return int.tryParse(value) ?? 0;
  }
  return value;
}

String createdAtFromJson(value){
  if(value is int){
    return DateTime.fromMicrosecondsSinceEpoch(value,isUtc: true).toString();
  }
  return value.toString();
}
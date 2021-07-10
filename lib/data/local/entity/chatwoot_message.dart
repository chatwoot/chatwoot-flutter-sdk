
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_message.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class ChatwootMessage extends Equatable{

  @JsonKey()
  @HiveField(0)
  final String id;

  @JsonKey()
  @HiveField(1)
  final String content;

  @JsonKey(name:"message_type")
  @HiveField(2)
  final String messageType;

  @JsonKey(name:"content_type")
  @HiveField(3)
  final String contentType;

  @JsonKey(name:"content_attributes")
  @HiveField(4)
  final String contentAttributes;

  @JsonKey(name:"created_at")
  @HiveField(5)
  final String createdAt;

  @JsonKey(name:"conversation_id")
  @HiveField(6)
  final String conversationId;

  @JsonKey()
  @HiveField(7)
  final List<dynamic> attachments;

  @JsonKey(name:"sender")
  @HiveField(8)
  final dynamic sender;

  bool get isMine => messageType == "1";

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
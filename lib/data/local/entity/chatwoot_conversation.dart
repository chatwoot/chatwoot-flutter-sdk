

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'chatwoot_conversation.g.dart';



@JsonSerializable()
@HiveType(typeId: 1)
class ChatwootConversation extends Equatable{

  @JsonKey()
  @HiveField(0)
  final int id;

  @JsonKey(name: "inbox_id")
  @HiveField(1)
  final String inboxId;

  @JsonKey()
  @HiveField(2)
  final String messages;

  @JsonKey()
  @HiveField(3)
  final String contact;

  ChatwootConversation({
    required this.id,
    required this.inboxId,
    required this.messages,
    required this.contact
  });

  factory ChatwootConversation.fromJson(Map<String, dynamic> json) => _$ChatwootConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootConversationToJson(this);

  @override
  List<Object?> get props => [
    id,
    inboxId,
    messages,
    contact
  ];

}
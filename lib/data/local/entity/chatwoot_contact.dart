
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_contact.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class ChatwootContact extends Equatable{

  static const BOX_NAME = "ChatwootContact";

  @JsonKey(name: "id")
  @HiveField(0)
  final int id;

  @JsonKey(name: "source_id")
  @HiveField(1)
  final String contactIdentifier;

  @JsonKey(name: "pubsub_token")
  @HiveField(2)
  final String pubsubToken;

  @JsonKey()
  @HiveField(3)
  final String name;

  @JsonKey()
  @HiveField(4)
  final String email;

  ChatwootContact({
    required this.id,
    required this.contactIdentifier,
    required this.pubsubToken,
    required this.name,
    required this.email,
  });

  factory ChatwootContact.fromJson(Map<String, dynamic> json) => _$ChatwootContactFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootContactToJson(this);

  @override
  List<Object?> get props => [
    id,
    contactIdentifier,
    pubsubToken,
    name,
    email
  ];

}

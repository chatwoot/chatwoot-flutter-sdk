
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_user.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class ChatwootUser extends Equatable{

  @JsonKey()
  @HiveField(0)
  final String? identifier;

  @JsonKey()
  @HiveField(1)
  final String? identifierHash;

  @JsonKey()
  @HiveField(2)
  final String? name;

  @JsonKey()
  @HiveField(3)
  final String? email;

  @JsonKey(name: "avatar_url")
  @HiveField(4)
  final String? avatarUrl;

  @JsonKey(name: "custom_attributes")
  @HiveField(5)
  final dynamic customAttributes;

  ChatwootUser({
    this.identifier,
    this.identifierHash,
    this.name,
    this.email,
    this.avatarUrl,
    this.customAttributes
  });

  @override
  List<Object?> get props => [
    identifier,
    identifierHash,
    name,
    email,
    avatarUrl,
    customAttributes
  ];


  factory ChatwootUser.fromJson(Map<String, dynamic> json) => _$ChatwootUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootUserToJson(this);

}

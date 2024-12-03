import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'chatwoot_user.g.dart';

///
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: CHATWOOT_USER_HIVE_TYPE_ID)
class ChatwootUser extends Equatable {
  ///custom chatwoot user identifier
  @JsonKey()
  @HiveField(0)
  final String? identifier;

  ///custom user identifier hash
  @JsonKey(name: "identifier_hash")
  @HiveField(1)
  final String? identifierHash;

  ///name of chatwoot user
  @JsonKey()
  @HiveField(2)
  final String? name;

  ///email of chatwoot user
  @JsonKey()
  @HiveField(3)
  final String? email;

  ///profile picture url of user
  @JsonKey(name: "avatar_url")
  @HiveField(4)
  final String? avatarUrl;

  ///phone number of user
  @JsonKey(name: "phone_number")
  @HiveField(6)
  final String? phoneNumber;

  ///any other custom attributes to be linked to the user
  @JsonKey(name: "custom_attributes")
  @HiveField(5)
  final dynamic customAttributes;

  ChatwootUser(
      {this.identifier,
      this.identifierHash,
      this.name,
      this.email,
      this.phoneNumber,
      this.avatarUrl,
      this.customAttributes});

  @override
  List<Object?> get props =>
      [identifier, identifierHash, name, email, avatarUrl, customAttributes];

  factory ChatwootUser.fromJson(Map<String, dynamic> json) =>
      _$ChatwootUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootUserToJson(this);
}

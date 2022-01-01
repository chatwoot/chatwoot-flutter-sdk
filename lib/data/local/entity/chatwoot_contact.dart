import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'chatwoot_contact.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: CHATWOOT_CONTACT_HIVE_TYPE_ID)
class ChatwootContact extends Equatable {
  ///unique identifier of contact
  @JsonKey(name: "id")
  @HiveField(0)
  final int id;

  ///Source id of contact obtained on contact create
  @JsonKey(name: "source_id")
  @HiveField(1)
  final String? contactIdentifier;

  ///Token for subscribing to websocket stream events
  @JsonKey(name: "pubsub_token")
  @HiveField(2)
  final String? pubsubToken;

  ///Full name of contact
  @JsonKey()
  @HiveField(3)
  final String name;

  ///Email of contact
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

  factory ChatwootContact.fromJson(Map<String, dynamic> json) =>
      _$ChatwootContactFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootContactToJson(this);

  @override
  List<Object?> get props => [id, contactIdentifier, pubsubToken, name, email];
}

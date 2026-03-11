// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootAction _$ChatwootActionFromJson(Map<String, dynamic> json) =>
    ChatwootAction(
      identifier: json['identifier'] as String,
      data: json['data'] == null
          ? null
          : ChatwootActionData.fromJson(json['data'] as Map<String, dynamic>),
      command: json['command'] as String,
    );

Map<String, dynamic> _$ChatwootActionToJson(ChatwootAction instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'command': instance.command,
      'data': instance.data?.toJson(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_action_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootActionData _$ChatwootActionDataFromJson(Map<String, dynamic> json) =>
    ChatwootActionData(
      action: actionTypeFromJson(json['action'] as String?),
    );

Map<String, dynamic> _$ChatwootActionDataToJson(ChatwootActionData instance) =>
    <String, dynamic>{
      'action': actionTypeToJson(instance.action),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatwoot_new_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatwootNewMessageRequest _$ChatwootNewMessageRequestFromJson(
        Map<String, dynamic> json) =>
    ChatwootNewMessageRequest(
      content: json['content'] as String,
      echoId: json['echo_id'] as String,
      contentAttributes: json['content_attributes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatwootNewMessageRequestToJson(
        ChatwootNewMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'echo_id': instance.echoId,
      'content_attributes': instance.contentAttributes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csat_survey_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CsatSurveyFeedbackResponse _$CsatSurveyFeedbackResponseFromJson(
        Map<String, dynamic> json) =>
    CsatSurveyFeedbackResponse(
      id: (json['id'] as num?)?.toInt(),
      csatSurveyResponse: json['csat_survey_response'] == null
          ? null
          : CsatResponse.fromJson(
              json['csat_survey_response'] as Map<String, dynamic>),
      inboxAvatarUrl: json['inbox_avatar_url'] as String?,
      inboxName: json['inbox_name'] as String?,
      locale: json['locale'] as String?,
      conversationId: (json['consversation_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$CsatSurveyFeedbackResponseToJson(
        CsatSurveyFeedbackResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'csat_survey_response': instance.csatSurveyResponse?.toJson(),
      'inbox_avatar_url': instance.inboxAvatarUrl,
      'inbox_name': instance.inboxName,
      'locale': instance.locale,
      'consversation_id': instance.conversationId,
      'created_at': instance.createdAt,
    };

CsatResponse _$CsatResponseFromJson(Map<String, dynamic> json) => CsatResponse(
      id: (json['id'] as num?)?.toInt(),
      accountId: (json['account_id'] as num?)?.toInt(),
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      messageId: (json['message_id'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toInt(),
      feedbackMessage: json['feedback_message'] as String?,
      contactId: (json['contact_id'] as num?)?.toInt(),
      assignedAgentId: (json['assigned_agent_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CsatResponseToJson(CsatResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'rating': instance.rating,
      'feedback_message': instance.feedbackMessage,
      'contact_id': instance.contactId,
      'assigned_agent_id': instance.assignedAgentId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_csat_survey_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendCsatSurveyRequest _$SendCsatSurveyRequestFromJson(
        Map<String, dynamic> json) =>
    SendCsatSurveyRequest(
      rating: (json['rating'] as num).toInt(),
      feedbackMessage: json['feedback_message'] as String,
    );

Map<String, dynamic> _$SendCsatSurveyRequestToJson(
        SendCsatSurveyRequest instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'feedback_message': instance.feedbackMessage,
    };

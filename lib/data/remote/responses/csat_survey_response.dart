

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'csat_survey_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CsatSurveyFeedbackResponse extends Equatable{
  @JsonKey()
  final int? id;
  @JsonKey(name: "csat_survey_response")
  final CsatResponse? csatSurveyResponse;
  @JsonKey(name: "inbox_avatar_url")
  final String? inboxAvatarUrl;
  @JsonKey(name: "inbox_name")
  final String? inboxName;
  @JsonKey(name: "locale")
  final String? locale;
  @JsonKey(name: "consversation_id")
  final int? conversationId;
  @JsonKey(name: "created_at")
  final String? createdAt;

  CsatSurveyFeedbackResponse(
      {this.id,
        this.csatSurveyResponse,
        this.inboxAvatarUrl,
        this.inboxName,
        this.locale,
        this.conversationId,
        this.createdAt});



  factory CsatSurveyFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$CsatSurveyFeedbackResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CsatSurveyFeedbackResponseToJson(this);

  @override
  List<Object?> get props => [
    this.id,
    this.csatSurveyResponse,
    this.inboxAvatarUrl,
    this.inboxName,
    this.conversationId,
    this.locale,
    this.createdAt
  ];
}

@JsonSerializable(explicitToJson: true)
class CsatResponse extends Equatable{
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "account_id")
  final int? accountId;
  @JsonKey(name: "conversation_id")
  final int? conversationId;
  @JsonKey(name: "message_id")
  final int? messageId;
  @JsonKey(name: "rating")
  final int? rating;
  @JsonKey(name: "feedback_message")
  final String? feedbackMessage;
  @JsonKey(name: "contact_id")
  final int? contactId;
  @JsonKey(name: "assigned_agent_id")
  final int? assignedAgentId;
  @JsonKey(name: "created_at")
  final String? createdAt;
  @JsonKey(name: "updated_at")
  final String? updatedAt;

  CsatResponse(
      {this.id,
        this.accountId,
        this.conversationId,
        this.messageId,
        this.rating,
        this.feedbackMessage,
        this.contactId,
        this.assignedAgentId,
        this.createdAt,
        this.updatedAt});



  factory CsatResponse.fromJson(Map<String, dynamic> json) =>
      _$CsatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CsatResponseToJson(this);

  @override
  List<Object?> get props => [
    this.id,
    this.accountId,
    this.conversationId,
    this.messageId,
    this.rating,
    this.feedbackMessage,
    this.contactId,
    this.assignedAgentId,
    this.createdAt,
    this.updatedAt
  ];
}
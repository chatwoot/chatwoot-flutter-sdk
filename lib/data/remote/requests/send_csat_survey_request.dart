import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


part 'send_csat_survey_request.g.dart';

@JsonSerializable(explicitToJson: true)
class SendCsatSurveyRequest extends Equatable{
  @JsonKey(name: "rating")
  final int rating;

  @JsonKey(name: "feedback_message")
  final String feedbackMessage;


  SendCsatSurveyRequest({required this.rating, required this.feedbackMessage});

  factory SendCsatSurveyRequest.fromJson(Map<String, dynamic> json) =>
      _$SendCsatSurveyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendCsatSurveyRequestToJson(this);

  @override
  List<Object?> get props => [
    this.rating,
    this.feedbackMessage
  ];
}

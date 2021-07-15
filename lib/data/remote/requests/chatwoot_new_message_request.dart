import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_new_message_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatwootNewMessageRequest extends Equatable {
  @JsonKey()
  final String content;
  @JsonKey(name: "echo_id")
  final String echoId;

  ChatwootNewMessageRequest({required this.content, required this.echoId});

  @override
  List<Object> get props => [content, echoId];

  factory ChatwootNewMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatwootNewMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootNewMessageRequestToJson(this);
}

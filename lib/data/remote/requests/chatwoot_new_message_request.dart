
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


part 'chatwoot_new_message_request.g.dart';

@JsonSerializable()
class ChatwootNewMessageRequest extends Equatable{

  @JsonKey()
  final String content;
  @JsonKey(name: "echo_id")
  final String echoId;

  ChatwootNewMessageRequest({
    required this.content,
    required this.echoId
  });


  @override
  List<Object> get props => [
    content,
    echoId
  ];
}

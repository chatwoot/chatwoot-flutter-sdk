import 'package:chatwoot_sdk/ui/chatwoot_chat_page.dart';
import 'package:equatable/equatable.dart';



class ChatwootNewMessageRequest extends Equatable {
  final String content;
  final String echoId;
  final List<FileAttachment> attachments;

  ChatwootNewMessageRequest({required this.content, required this.echoId, this.attachments = const[]});

  @override
  List<Object> get props => [content, echoId];

}

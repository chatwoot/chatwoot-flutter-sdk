import 'package:json_annotation/json_annotation.dart';

part 'chatwoot_action_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatwootActionData {
  @JsonKey(toJson: actionTypeToJson, fromJson: actionTypeFromJson)
  final ChatwootActionType action;

  ChatwootActionData({required this.action});

  factory ChatwootActionData.fromJson(Map<String, dynamic> json) =>
      _$ChatwootActionDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatwootActionDataToJson(this);
}

enum ChatwootActionType { subscribe, update_presence, startTyping, stopTyping }

String actionTypeToJson(ChatwootActionType actionType) {
  switch (actionType) {
    case ChatwootActionType.update_presence:
      return "update_presence";
    case ChatwootActionType.subscribe:
      return "subscribe";
    case ChatwootActionType.startTyping:
      return "start_typing";
    case ChatwootActionType.stopTyping:
      return "stop_typing";
  }
}

ChatwootActionType actionTypeFromJson(String? value) {
  switch (value) {
    case "update_presence":
      return ChatwootActionType.update_presence;
    case "subscribe":
      return ChatwootActionType.subscribe;
    case "start_typing":
      return ChatwootActionType.startTyping;
    case "stop_typing":
      return ChatwootActionType.stopTyping;
    default:
      return ChatwootActionType.update_presence;
  }
}

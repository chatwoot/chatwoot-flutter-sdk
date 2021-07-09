
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';

class ChatwootCallbacks{
  void Function(dynamic)? onWelcome;
  void Function(dynamic)? onPing;
  void Function(dynamic)? onConfirmedSubscription;
  void Function(ChatwootMessage)? onMessageCreated;
  void Function(ChatwootMessage)? onMyMessageSent;
  void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;
  void Function(List<ChatwootMessage>)? onMessagesRetrieved;
  void Function(String)? onError;

  ChatwootCallbacks({
    this.onWelcome,
    this.onPing,
    this.onConfirmedSubscription,
    this.onMessageCreated,
    this.onMyMessageSent,
    this.onPersistedMessagesRetrieved,
    this.onMessagesRetrieved,
    this.onError,
  });
}
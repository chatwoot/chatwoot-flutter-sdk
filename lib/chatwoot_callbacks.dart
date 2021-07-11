
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';

class ChatwootCallbacks{
  void Function(dynamic)? onWelcome;
  void Function(dynamic)? onPing;
  void Function(dynamic)? onConfirmedSubscription;
  void Function(ChatwootMessage)? onMessageReceived;
  void Function(ChatwootMessage, String)? onMessageSent;
  void Function(ChatwootMessage, String)? onMessageDelivered;
  void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;
  void Function(List<ChatwootMessage>)? onMessagesRetrieved;
  void Function(ChatwootClientException)? onError;

  ChatwootCallbacks({
    this.onWelcome,
    this.onPing,
    this.onConfirmedSubscription,
    this.onMessageReceived,
    this.onMessageSent,
    this.onMessageDelivered,
    this.onPersistedMessagesRetrieved,
    this.onMessagesRetrieved,
    this.onError,
  });
}

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_client_sdk/data/remote/responses/chatwoot_event.dart';

class ChatwootCallbacks{
  void Function(ChatwootEvent)? onWelcome;
  void Function(ChatwootEvent)? onPing;
  void Function(ChatwootEvent)? onConfirmedSubscription;
  void Function(ChatwootEvent)? onConversationStartedTyping;
  void Function(ChatwootEvent)? onConversationStoppedTyping;
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
    this.onConversationStartedTyping,
    this.onConversationStoppedTyping,
    this.onError,
  });
}
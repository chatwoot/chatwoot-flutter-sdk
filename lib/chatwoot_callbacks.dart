import 'package:chatwoot_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/data/remote/responses/chatwoot_event.dart';
import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';

///Chatwoot callback are specified for each created client instance. Methods are triggered
///when a method satisfying their respective conditions occur.
///
///
/// {@category FlutterClientSdk}
class ChatwootCallbacks {
  ///Triggered when a welcome event/message is received after connecting to
  ///the chatwoot websocket. See [ChatwootRepository.listenForEvents]
  void Function()? onWelcome;

  ///Triggered when a ping event/message is received after connecting to
  ///the chatwoot websocket. See [ChatwootRepository.listenForEvents]
  void Function()? onPing;

  ///Triggered when a subscription confirmation event/message is received after connecting to
  ///the chatwoot websocket. See [ChatwootRepository.listenForEvents]
  void Function()? onConfirmedSubscription;

  ///Triggered when a conversation typing on event/message [ChatwootEventMessageType.conversation_typing_on]
  ///is received after connecting to the chatwoot websocket. See [ChatwootRepository.listenForEvents]
  void Function()? onConversationStartedTyping;

  ///Triggered when a presence update event/message [ChatwootEventMessageType.presence_update]
  ///is received after connecting to the chatwoot websocket and conversation is online. See [ChatwootRepository.listenForEvents]
  void Function()? onConversationIsOnline;

  ///Triggered when a presence update event/message [ChatwootEventMessageType.presence_update]
  ///is received after connecting to the chatwoot websocket and conversation is offline.
  ///See [ChatwootRepository.listenForEvents]
  void Function()? onConversationIsOffline;

  ///Triggered when a conversation typing off event/message [ChatwootEventMessageType.conversation_typing_off]
  ///is received after connecting to the chatwoot websocket. See [ChatwootRepository.listenForEvents]
  void Function()? onConversationStoppedTyping;

  ///Triggered when a message created event/message [ChatwootEventMessageType.message_created]
  ///is received and message doesn't belong to current user after connecting to the chatwoot websocket.
  ///See [ChatwootRepository.listenForEvents]
  void Function(ChatwootMessage)? onMessageReceived;

  ///Triggered when a message created event/message [ChatwootEventMessageType.message_updated]
  ///is received after connecting to the chatwoot websocket.
  ///See [ChatwootRepository.listenForEvents]
  void Function(ChatwootMessage)? onMessageUpdated;

  void Function(ChatwootMessage, String)? onMessageSent;

  ///Triggered when a message created event/message [ChatwootEventMessageType.message_created]
  ///is received and message belongs to current user after connecting to the chatwoot websocket.
  ///See [ChatwootRepository.listenForEvents]
  void Function(ChatwootMessage, String)? onMessageDelivered;

  ///Triggered when a conversation's messages persisted on device are successfully retrieved
  void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;

  ///Triggered when a conversation's messages is successfully retrieved from remote server
  void Function(List<ChatwootMessage>)? onMessagesRetrieved;

  ///Triggered when an agent resolves the current conversation
  void Function(String)? onConversationResolved;

  ///Triggered when csat feedbaack is sent
  void Function(CsatSurveyFeedbackResponse)? onCsatSurveyResponseRecorded;

  /// Triggered when any error occurs in chatwoot client's operations with the error
  ///
  /// See [ChatwootClientExceptionType] for the various types of exceptions that can be triggered
  void Function(ChatwootClientException)? onError;

  ChatwootCallbacks({
    this.onWelcome,
    this.onPing,
    this.onConfirmedSubscription,
    this.onMessageReceived,
    this.onMessageSent,
    this.onMessageDelivered,
    this.onMessageUpdated,
    this.onPersistedMessagesRetrieved,
    this.onMessagesRetrieved,
    this.onConversationStartedTyping,
    this.onConversationStoppedTyping,
    this.onConversationIsOnline,
    this.onConversationIsOffline,
    this.onConversationResolved,
    this.onCsatSurveyResponseRecorded,
    this.onError,
  });
}

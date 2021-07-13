library chatwoot_client_sdk;

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/chatwoot_client.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

class ChatwootChatPage extends StatefulWidget {

  /// Specifies a custom app bar for chatwoot page widget
  final PreferredSizeWidget? appBar;

  ///Installation url for chatwoot
  final String baseUrl;

  ///Identifier for target chatwoot inbox.
  ///
  /// For more details see https://www.chatwoot.com/docs/product/channels/api/client-apis
  final String inboxIdentifier;

  /// Enables persistence of chatwoot client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds chatwoot client instance's data in memory and is cleared as
  /// soon as chatwoot client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to chatwoot contact
  final ChatwootUser? user;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText)? onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// See [Message.showUserAvatars]
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  final ChatTheme? theme;

  ///See [ChatwootCallbacks.onWelcome]
  final void Function()? onWelcome;

  ///See [ChatwootCallbacks.onPing]
  final void Function()? onPing;

  ///See [ChatwootCallbacks.onConfirmedSubscription]
  final void Function()? onConfirmedSubscription;

  ///See [ChatwootCallbacks.onConversationStartedTyping]
  final void Function()? onConversationStartedTyping;

  ///See [ChatwootCallbacks.onConversationIsOnline]
  final void Function()? onConversationIsOnline;

  ///See [ChatwootCallbacks.onConversationIsOffline]
  final void Function()? onConversationIsOffline;

  ///See [ChatwootCallbacks.onConversationStoppedTyping]
  final void Function()? onConversationStoppedTyping;

  ///See [ChatwootCallbacks.onMessageReceived]
  final void Function(ChatwootMessage)? onMessageReceived;

  ///See [ChatwootCallbacks.onMessageSent]
  final void Function(ChatwootMessage)? onMessageSent;

  ///See [ChatwootCallbacks.onMessageDelivered]
  final void Function(ChatwootMessage)? onMessageDelivered;

  ///See [ChatwootCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;

  ///See [ChatwootCallbacks.onMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onMessagesRetrieved;

  ///See [ChatwootCallbacks.onError]
  final void Function(ChatwootClientException)? onError;



  const ChatwootChatPage({
    Key? key,
    required this.baseUrl,
    required this.inboxIdentifier,
    this.enablePersistence = true,
    this.user,
    this.appBar,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageLongPress,
    this.onMessageTap,
    this.onSendPressed,
    this.onTextChanged,
    this.showUserAvatars = true,
    this.showUserNames = true,
    this.theme,
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
    this.onConversationIsOnline,
    this.onConversationIsOffline,
    this.onError,
  }) : super(key: key);

  @override
  _ChatwootChatPageState createState() => _ChatwootChatPageState();
}

class _ChatwootChatPageState extends State<ChatwootChatPage> {

  ///
  List<types.Message> _messages = [];

  final onlineStatus= "online";
  final typingStatus= "typing...";
  final awayStatus= "We're away at the moment";

  late String status;

  final idGen = Uuid();
  late final _user;
  late final ChatwootClient chatwootClient;

  late final chatwootCallbacks;

  @override
  void initState() {
    super.initState();

    status = awayStatus;

    if(widget.user == null){
      _user = types.User(id: idGen.v4());
    }else{
      _user = types.User(
        id: widget.user?.identifier ?? idGen.v4(),
        firstName: widget.user?.name,
        imageUrl: widget.user?.avatarUrl,
      );
    }

    chatwootCallbacks = ChatwootCallbacks(
      onWelcome: (){
        widget.onWelcome?.call();
      },
      onPing: (){
        widget.onPing?.call();
      },
      onConfirmedSubscription: (){
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: (){
        setState(() {
          status = typingStatus;
        });
        widget.onConversationStoppedTyping?.call();
      },
      onConversationStoppedTyping: (){
        setState(() {
          if(status != awayStatus){
            status = onlineStatus;
          }
        });
        widget.onConversationStartedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages){
        if(widget.enablePersistence){
          setState(() {
            _messages = persistedMessages.map((message)=> _chatwootMessageToTextMessage(message)).toList();
          });
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages){
        if(messages.isEmpty){
          return;
        }
        setState(() {
          final chatMessages = messages.map((message)=> _chatwootMessageToTextMessage(message)).toList();
          final mergedMessages = <types.Message>[..._messages,...chatMessages].toSet().toList();
          final now = DateTime.now().microsecondsSinceEpoch;
          mergedMessages.sort((a,b){
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
          _messages = mergedMessages;
        });
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (chatwootMessage){
        _addMessage(_chatwootMessageToTextMessage(chatwootMessage));
        widget.onMessageReceived?.call(chatwootMessage);
      },
      onMessageDelivered: (chatwootMessage, echoId){
        _handleMessageSent(_chatwootMessageToTextMessage(chatwootMessage, echoId: echoId));
        widget.onMessageDelivered?.call(chatwootMessage);
      },
      onMessageSent: (chatwootMessage, echoId){
        final textMessage = types.TextMessage(
            id: echoId,
            author: _user,
            text: chatwootMessage.content ?? "",
            status: types.Status.delivered
        );
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(chatwootMessage);
      },
      onError: (error){
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        widget.onError?.call(error);
      },
    );


    ChatwootClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        enableMessagesPersistence: widget.enablePersistence,
        callbacks: chatwootCallbacks
    ).then((client) {
      setState(() {
        chatwootClient = client;
        chatwootClient.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(ChatwootClientException(error.toString(), ChatwootClientExceptionType.CREATE_CLIENT_FAILED));
      print("chatwoot client failed with error $error: $stackTrace");
    });

  }

  types.TextMessage _chatwootMessageToTextMessage(ChatwootMessage message, {String? echoId}){
    return types.TextMessage(
        id: echoId ?? message.id.toString(),
        author: message.isMine ? _user : types.User(
          id: message.sender?.id.toString() ?? idGen.v4(),
          firstName: message.sender?.name,
          imageUrl: message.sender?.avatarUrl ?? message.sender?.thumbnail,
        ),
        text: message.content ?? "",
        status: types.Status.seen
    );
  }


  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }


  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
    widget.onMessageTap?.call(message);
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleMessageSent(
      types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    if(_messages[index].status == types.Status.seen){
      return;
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().microsecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    chatwootClient.sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(message);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Chat(
          messages: _messages,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
          onEndReached: widget.onEndReached,
          onEndReachedThreshold: widget.onEndReachedThreshold,
          onMessageLongPress: widget.onMessageLongPress,
          onTextChanged: widget.onTextChanged,
          showUserAvatars: widget.showUserAvatars,
          showUserNames: widget.showUserNames,
          theme: widget.theme ?? DefaultChatTheme(
            inputBackgroundColor: Colors.blue.withOpacity(0.5),
            inputTextColor: Colors.black,
          ),
          l10n: ChatL10nEn(
            emptyChatPlaceholder: "",
          ),
        ),
      ),
    );
  }
}


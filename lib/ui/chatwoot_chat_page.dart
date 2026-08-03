import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/ui/chatwoot_chat_theme.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

///Chatwoot chat widget
/// {@category FlutterClientSdk}
class ChatwootChat extends StatefulWidget {
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
  final void Function(BuildContext context, core.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(BuildContext context, core.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText)? onSendPressed;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final dynamic theme;

  /// See [ChatwootL10n]
  final ChatwootL10n l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

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

  ///See [ChatwootCallbacks.onMessageUpdated]
  final void Function(ChatwootMessage)? onMessageUpdated;

  ///See [ChatwootCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;

  ///See [ChatwootCallbacks.onMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onMessagesRetrieved;

  ///See [ChatwootCallbacks.onError]
  final void Function(ChatwootClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const ChatwootChat(
      {Key? key,
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
      this.showUserAvatars = true,
      this.showUserNames = true,
      this.theme,
      this.l10n = const ChatwootL10n(),
      this.timeFormat,
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
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _ChatwootChatState createState() => _ChatwootChatState();
}

class _ChatwootChatState extends State<ChatwootChat> {
  late final core.InMemoryChatController _chatController;
  final Map<String, core.User> _userCache = {};

  late String status;

  final idGen = Uuid();
  late final core.User _user;
  ChatwootClient? chatwootClient;

  late final chatwootCallbacks;

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      _user = core.User(id: idGen.v4());
    } else {
      _user = core.User(
        id: widget.user?.identifier ?? idGen.v4(),
        name: widget.user?.name,
        imageSource: widget.user?.avatarUrl,
      );
    }
    _userCache[_user.id] = _user;

    _chatController = core.InMemoryChatController(messages: []);

    chatwootCallbacks = ChatwootCallbacks(
      onWelcome: () {
        widget.onWelcome?.call();
      },
      onPing: () {
        widget.onPing?.call();
      },
      onConfirmedSubscription: () {
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          final messages = persistedMessages
              .map((message) => _chatwootMessageToTextMessage(message))
              .toList();
          _chatController.setMessages(messages);
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        final chatMessages = messages
            .map((message) => _chatwootMessageToTextMessage(message))
            .toList();

        final currentMessages = _chatController.messages;
        final mergedMessages = <core.Message>[
          ...currentMessages,
          ...chatMessages
        ].toSet().toList();
        final now = DateTime.now();
        mergedMessages.sort((a, b) {
          final aTime = a.createdAt ?? now;
          final bTime = b.createdAt ?? now;
          return bTime.compareTo(aTime);
        });
        _chatController.setMessages(mergedMessages);

        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (chatwootMessage) {
        _chatController
            .insertMessage(_chatwootMessageToTextMessage(chatwootMessage));
        widget.onMessageReceived?.call(chatwootMessage);
      },
      onMessageDelivered: (chatwootMessage, echoId) {
        _handleMessageSent(
            _chatwootMessageToTextMessage(chatwootMessage, echoId: echoId));
        widget.onMessageDelivered?.call(chatwootMessage);
      },
      onMessageUpdated: (chatwootMessage) {
        _handleMessageUpdated(_chatwootMessageToTextMessage(chatwootMessage,
            echoId: chatwootMessage.id.toString()));
        widget.onMessageUpdated?.call(chatwootMessage);
      },
      onMessageSent: (chatwootMessage, echoId) {
        final textMessage = core.TextMessage(
          id: echoId,
          authorId: _user.id,
          text: chatwootMessage.content ?? "",
          // Status is gone. Use metadata or timestamps.
          // For "delivered", we might set deliveredAt?
          // But here it's just "sent" callback.
          // We can set metadata: {'status': 'delivered'} if we want custom handling
          // or just rely on default behavior.
          // Let's set metadata for now to match legacy behavior if needed.
          metadata: {'status': 'delivered'},
          createdAt: DateTime.now(),
        );
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(chatwootMessage);
      },
      onConversationResolved: () {
        final botUser = core.User(
            id: idGen.v4(),
            name: "Bot",
            imageSource:
                "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png");
        _userCache[botUser.id] = botUser;

        final resolvedMessage = core.TextMessage(
          id: idGen.v4(),
          text: widget.l10n.conversationResolvedMessage,
          authorId: botUser.id,
          metadata: {'status': 'delivered'},
          createdAt: DateTime.now(),
        );
        _chatController.insertMessage(resolvedMessage);
      },
      onError: (error) {
        if (error.type == ChatwootClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        widget.onError?.call(error);
      },
    );

    ChatwootClient.create(
            baseUrl: widget.baseUrl,
            inboxIdentifier: widget.inboxIdentifier,
            user: widget.user,
            enablePersistence: widget.enablePersistence,
            callbacks: chatwootCallbacks)
        .then((client) {
      setState(() {
        chatwootClient = client;
        chatwootClient!.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(ChatwootClientException(
          error.toString(), ChatwootClientExceptionType.CREATE_CLIENT_FAILED));
      print("chatwoot client failed with error $error: $stackTrace");
    });
  }

  core.TextMessage _chatwootMessageToTextMessage(ChatwootMessage message,
      {String? echoId}) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }

    final author = message.isMine
        ? _user
        : core.User(
            id: message.sender?.id.toString() ?? idGen.v4(),
            name: message.sender?.name,
            imageSource: avatarUrl,
          );
    _userCache[author.id] = author;

    return core.TextMessage(
        id: echoId ?? message.id.toString(),
        authorId: author.id,
        text: message.content ?? "",
        // status: types.Status.seen, // Gone
        metadata: {'status': 'seen'}, // Placeholder
        createdAt: DateTime.parse(message.createdAt));
  }

  void _handleSendMessageFailed(String echoId) async {
    final message =
        _chatController.messages.firstWhere((element) => element.id == echoId);
    final updatedMessage = message.copyWith(metadata: {'status': 'error'});
    _chatController.updateMessage(message, updatedMessage);
  }

  void _handleResendMessage(core.TextMessage message) async {
    chatwootClient!.sendMessage(content: message.text, echoId: message.id);
    final updatedMessage = message.copyWith(metadata: {'status': 'sending'});
    _chatController.updateMessage(message, updatedMessage);
  }

  void _handleMessageTap(BuildContext context, core.Message message) async {
    if (message.metadata?['status'] == 'error' && message is core.TextMessage) {
      _handleResendMessage(message);
    }
    widget.onMessageTap?.call(context, message);
  }

  void _handleMessageSent(
    core.Message message,
  ) {
    // Check if message exists, if so update it, else insert?
    // Usually handleMessageSent is called after we already inserted it as "sending".
    // So we should update.
    // But if it's a new message from other user, we insert.
    // Here it seems to be used for updating status.

    // We need to find if message exists.
    final existingIndex = _chatController.messages
        .indexWhere((element) => element.id == message.id);
    if (existingIndex != -1) {
      final oldMessage = _chatController.messages[existingIndex];
      _chatController.updateMessage(oldMessage, message);
    } else {
      _chatController.insertMessage(message);
    }
  }

  void _handleMessageUpdated(
    core.Message message,
  ) {
    final existingIndex = _chatController.messages
        .indexWhere((element) => element.id == message.id);
    if (existingIndex != -1) {
      final oldMessage = _chatController.messages[existingIndex];
      _chatController.updateMessage(oldMessage, message);
    }
  }

  void _handleSendPressed(String text) {
    final textMessage = core.TextMessage(
      authorId: _user.id,
      createdAt: DateTime.now(),
      id: const Uuid().v4(),
      text: text,
      metadata: {'status': 'sending'},
    );

    _chatController.insertMessage(textMessage);
    chatwootClient!
        .sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(types.PartialText(text: text));
  }

  Future<core.User?> _resolveUser(String userId) async {
    return _userCache[userId] ?? core.User(id: userId, name: "Unknown");
  }

  @override
  Widget build(BuildContext context) {
    // The user wants to remove the theme initialization and use CHATWOOT_BG_COLOR directly.
    // Also, the theme parameter in Chat widget should be commented out.

    // final theme = widget.theme ??
    //     ChatTheme(
    //       colors: ChatThemeColors(
    //         primary: CHATWOOT_COLOR_PRIMARY,
    //         secondary: CHATWOOT_BG_COLOR,
    //         background: CHATWOOT_BG_COLOR,
    //         // Add other required colors or use defaults if possible
    //         // If ChatThemeColors is abstract or requires many params, this might be hard.
    //         // Let's try to find a default theme factory or subclass.
    //         // Search result didn't mention one.
    //         // But usually there is a default.
    //         // Let's try 'DefaultChatTheme' again? No, it failed.
    //         // Maybe 'NeutralChatTheme'?
    //       ),
    //     );
    // Wait, I can't guess ChatThemeColors params.
    // I'll try to use 'DefaultChatTheme' from 'flutter_chat_ui' if I missed an import?
    // No, I imported it.

    // Let's try to use 'ChatTheme' with NO params and see what happens.
    // Or maybe 'ChatTheme.fromType(ChatThemeType.light)'?

    // Actually, I'll try to use 'DefaultChatTheme' but maybe it's named 'LightChatTheme'?

    // Let's try 'LightChatTheme'.

    // final effectiveTheme = widget.theme ??
    //     const DefaultChatTheme( // I'll try DefaultChatTheme again, maybe I had a typo? No.
    //        // Maybe it's 'FlyerChatTheme'?
    //     );

    // Okay, I will try to use 'ChatTheme' and see errors.

    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: CHATWOOT_BG_COLOR, // Fallback
      body: Container(
        color: CHATWOOT_BG_COLOR,
        child: Chat(
          chatController: _chatController,
          currentUserId: _user.id,
          resolveUser: _resolveUser,
          onMessageTap: (BuildContext context, core.Message message,
              {int? index, dynamic details}) {
            _handleMessageTap(context, message);
          },
          onMessageSend: _handleSendPressed,
          onMessageLongPress: (BuildContext context, core.Message message,
              {int? index, dynamic details}) {
            widget.onMessageLongPress?.call(context, message);
          },
          timeFormat: widget.timeFormat,
          // theme: theme, // Commenting out theme for now
          // l10n: widget.l10n, // Not available in v2.9.1
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    chatwootClient?.dispose();
    _chatController.dispose();
  }
}

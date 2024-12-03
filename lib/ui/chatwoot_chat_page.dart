import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/ui/chat_input.dart';
import 'package:chatwoot_sdk/ui/chatwoot_chat_theme.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:chatwoot_sdk/ui/link_preview.dart';
import 'package:chatwoot_sdk/ui/media_widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FileAttachment {
  final Uint8List bytes;
  final String name;
  final String path;

  FileAttachment({required this.bytes, required this.name, required this.path});
}

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

  ///Key used to generate user identifier hash
  ///
  /// For more details see https://www.chatwoot.com/docs/product/channels/api/client-apis
  final String? userIdentityValidationKey;

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
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(String)? onSendPressed;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final ChatwootChatTheme? theme;

  /// See [ChatwootL10n]
  final ChatwootL10n l10n;

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

  final Future<FileAttachment?> Function()? onAttachmentPressed;

  final Future<void> Function(String)? openFile;

  ///See [ChatwootCallbacks.onError]
  final void Function(ChatwootClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const ChatwootChat(
      {Key? key,
      required this.baseUrl,
      required this.inboxIdentifier,
      this.userIdentityValidationKey,
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
      this.onAttachmentPressed,
      this.openFile,
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _ChatwootChatState createState() => _ChatwootChatState();
}

class _ChatwootChatState extends State<ChatwootChat>
    with WidgetsBindingObserver {
  ///
  List<types.Message> _messages = [];

  late String status;

  final idGen = Uuid();
  late final types.User _user;
  ChatwootClient? chatwootClient;

  late final ChatwootCallbacks chatwootCallbacks;

  @override
  void initState() {
    super.initState();
    if (widget.user == null) {
      _user = types.User(id: idGen.v4());
    } else {
      _user = types.User(
        id: widget.user?.identifier ?? idGen.v4(),
        firstName: widget.user?.name,
        imageUrl: widget.user?.avatarUrl,
      );
    }

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
      onConversationIsOnline: () {
        widget.onConversationIsOnline?.call();
      },
      onConversationIsOffline: () {
        widget.onConversationIsOffline?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          setState(() {
            _messages = persistedMessages
                .where((m) => m.contentType != "input_csat")
                .map((message) => _chatwootMessageToTextMessage(message))
                .toList();
          });
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        setState(() {
          final chatMessages = messages
              .where((m) => m.contentType != "input_csat")
              .map((message) {
            return _chatwootMessageToTextMessage(message);
          }).toList();
          final mergedMessages = mergeLists(
              list1: chatMessages,
              list2: _messages,
              getItemKey: (item) => item.id,
              merger: (item1, item2) => item1);
          final now = DateTime.now().millisecondsSinceEpoch;
          mergedMessages.sort((a, b) {
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
          _messages = mergedMessages;
        });
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (chatwootMessage) {
        if (chatwootMessage.contentType == "input_csat") {
          //csat message is handled manually
          return;
        }
        _addMessage(_chatwootMessageToTextMessage(chatwootMessage));
        widget.onMessageReceived?.call(chatwootMessage);
      },
      onMessageDelivered: (chatwootMessage, echoId) {
        widget.onMessageDelivered?.call(chatwootMessage);
      },
      onMessageUpdated: (chatwootMessage) {
        _handleMessageUpdated(_chatwootMessageToTextMessage(chatwootMessage,
            echoId: chatwootMessage.id.toString()));
        widget.onMessageUpdated?.call(chatwootMessage);
      },
      onMessageSent: (chatwootMessage, echoId) {
        types.Message textMessage = _chatwootMessageToTextMessage(
            chatwootMessage,
            echoId: echoId,
            messageStatus: types.Status.sent);
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(chatwootMessage);
      },
      onConversationResolved: (conversationUuid) {
        final resolvedMessage = types.TextMessage(
            id: "resolved",
            text: widget.l10n.conversationResolvedMessage,
            author: types.User(
              id: idGen.v4(),
            ),
            status: types.Status.delivered);
        _addMessage(resolvedMessage);
        final csatMessage = types.CustomMessage(
            id: "csat",
            author: types.User(
              id: idGen.v4(),
            ),
            metadata: {"conversationUuid": conversationUuid},
            status: types.Status.delivered);
        _addMessage(csatMessage);
      },
      onCsatSurveyResponseRecorded: (feedback) {
        final resolvedMessage = types.CustomMessage(
            id: "csat",
            author: types.User(id: idGen.v4()),
            metadata: {"feedback": feedback},
            status: types.Status.delivered);
        _handleMessageUpdated(resolvedMessage);
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
            userIdentityValidationKey: widget.userIdentityValidationKey,
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

  List<T> mergeLists<T, K>({
    required List<T> list1,
    required List<T> list2,
    required K Function(T item) getItemKey,
    required T Function(T item1, T item2) merger,
  }) {
    final Map<K, T> map = {};

    for (final item in list2) {
      final key = getItemKey(item);
      map[key] = item;
    }

    final List<T> result = [];

    // Merge items from list1 with list2 or add them directly if no match
    for (final item in list1) {
      final key = getItemKey(item);
      if (map.containsKey(key)) {
        result.add(merger(item, map[key]!));
        map.remove(key); // Remove matched item to prevent duplicates
      } else {
        result.add(item);
      }
    }

    // Add remaining items from list2 that were not matched
    result.addAll(map.values);

    return result;
  }

  types.Message _chatwootMessageToTextMessage(ChatwootMessage message,
      {String? echoId, types.Status? messageStatus}) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }
    final nameSplit = (message.sender?.name ?? "C ").split(" ");
    final firstName = nameSplit.first;
    final lastName = nameSplit.last;
    types.User author = message.isMine
        ? _user
        : types.User(
            id: message.sender?.id.toString() ?? idGen.v4(),
            firstName: firstName,
            lastName: lastName,
            imageUrl: avatarUrl,
          );
    final metadata = <String, dynamic>{
      "sentAt":
          DateFormat("MMM d, hh:mm a").format(DateTime.parse(message.createdAt))
    };
    if (message.attachments?.first.dataUrl?.isNotEmpty ?? false) {
      Uri uri = Uri.parse(message.attachments!.first.dataUrl!);

      // Get the last path segment from the URL (after the last '/')
      String fileName =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (message.attachments!.first.fileType == "image") {
        return types.ImageMessage(
            id: echoId ?? message.id.toString(),
            author: author,
            name: fileName,
            metadata: metadata,
            size: message.attachments!.first.fileSize ?? 0,
            uri: message.attachments!.first.dataUrl!,
            status: messageStatus ?? types.Status.seen,
            createdAt:
                DateTime.parse(message.createdAt).millisecondsSinceEpoch);
      } else if (message.attachments!.first.fileType == "audio") {
        return types.AudioMessage(
            id: echoId ?? message.id.toString(),
            author: author,
            duration: Duration.zero,
            name: fileName,
            metadata: metadata,
            size: message.attachments!.first.fileSize ?? 0,
            uri: message.attachments!.first.dataUrl!,
            status: messageStatus ?? types.Status.seen,
            createdAt:
                DateTime.parse(message.createdAt).millisecondsSinceEpoch);
      } else {
        return types.FileMessage(
            id: echoId ?? message.id.toString(),
            author: author,
            name: fileName,
            metadata: metadata,
            size: message.attachments!.first.fileSize ?? 0,
            uri: message.attachments!.first.dataUrl!,
            status: messageStatus ?? types.Status.seen,
            createdAt:
                DateTime.parse(message.createdAt).millisecondsSinceEpoch);
      }
    }

    return types.TextMessage(
        id: echoId ?? message.id.toString(),
        author: author,
        text: message.content ?? "",
        metadata: metadata,
        status: types.Status.seen,
        createdAt: DateTime.parse(message.createdAt).millisecondsSinceEpoch);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendMessageFailed(String echoId) async {
    final index = _messages.indexWhere((element) => element.id == echoId);
    setState(() {
      _messages[index] = _messages[index].copyWith(status: types.Status.error);
    });
  }

  void _handleResendMessage(types.TextMessage message) async {
    chatwootClient!.sendMessage(content: message.text, echoId: message.id);
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = message.copyWith(status: types.Status.sending);
    });
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMetaData = _messages[index].metadata ?? Map();
    updatedMetaData["previewData"] = previewData;
    final updatedMessage = _messages[index].copyWith(metadata: updatedMetaData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message.status == types.Status.error && message is types.TextMessage) {
      _handleResendMessage(message);
      return;
    }
    if ((message is types.FileMessage) && widget.openFile != null) {
      var localPath = message.uri;

      if (localPath.startsWith('http')) {
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        final cacheLocalPath = '$documentsDir/${message.name}';

        if (!File(cacheLocalPath).existsSync()) {
          final client = http.Client();
          final request = await client.get(Uri.parse(localPath));
          final bytes = request.bodyBytes;
          final file = File(cacheLocalPath);
          await file.writeAsBytes(bytes);
        }
        localPath = cacheLocalPath;
      }
      widget.onMessageTap?.call(context, message);

      await widget.openFile?.call(localPath);
    }

    if (message is types.ImageMessage) {
      final imageProvider = CachedNetworkImageProvider(message.uri);
      showImageViewer(context, imageProvider);
    }
  }

  void _handleMessageSent(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleMessageUpdated(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    if (index == -1) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleSendPressed(String message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message,
        status: types.Status.sending);

    _addMessage(textMessage);

    chatwootClient!
        .sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(message);
  }

  void _handleAttachmentPressed() async {
    final attachment = await widget.onAttachmentPressed?.call();
    if (attachment != null) {
      types.Message message;
      if (lookupMimeType(attachment.name)?.startsWith("image") ?? false) {
        message = types.ImageMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            name: attachment.name,
            uri: attachment.path,
            size: attachment.bytes.length,
            status: types.Status.sending);
      } else if (lookupMimeType(attachment.name)?.startsWith("audio") ??
          false) {
        message = types.AudioMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            name: attachment.name,
            uri: attachment.path,
            size: attachment.bytes.length,
            duration: Duration.zero,
            status: types.Status.sending);
      } else {
        message = types.FileMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            name: attachment.name,
            uri: attachment.path,
            size: attachment.bytes.length,
            status: types.Status.sending);
      }

      _addMessage(message);

      chatwootClient!.sendMessage(
          content: attachment.name,
          echoId: message.id,
          attachment: [attachment]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPresentedInDialog ? 8.0 : 16.0;
    final theme = widget.theme ?? ChatwootChatTheme();
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.theme?.backgroundColor,
      body: Stack(
        children: [
          //offscreen video player used to fetch first frame of video messages. media_kit screenshot doesn't work without
          //actual chat
          Column(
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: horizontalPadding, right: horizontalPadding),
                  child: Chat(
                    messages: _messages,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: (_, __) {},
                    onSendPressed: (_) {},
                    user: _user,
                    onEndReached: widget.onEndReached,
                    onEndReachedThreshold: widget.onEndReachedThreshold,
                    onMessageLongPress: widget.onMessageLongPress,
                    onAttachmentPressed: () {},
                    showUserAvatars: widget.showUserAvatars,
                    showUserNames: widget.showUserNames,
                    theme: theme,
                    disableImageGallery: true,
                    dateHeaderBuilder: (_) {
                      return SizedBox();
                    },
                    customBottomWidget: ChatInput(
                        theme: theme,
                        l10n: widget.l10n,
                        onMessageSent: _handleSendPressed,
                        onAttachmentPressed: _handleAttachmentPressed),
                    textMessageBuilder: (message,
                        {messageWidth = 0, showName = true}) {
                      return TextChatMessage(
                          theme: theme,
                          message: message,
                          isMine: message.author.id == _user.id,
                          maxWidth: messageWidth,
                          onPreviewFetched: _handlePreviewDataFetched);
                    },
                    videoMessageBuilder: (message, {messageWidth = 0}) {
                      return VideoChatMessage(
                          theme: theme,
                          message: message,
                          isMine: message.author.id == _user.id,
                          maxWidth: messageWidth);
                    },
                    audioMessageBuilder: (message, {messageWidth = 0}) {
                      return AudioChatMessage(
                        theme: theme,
                        message: message,
                        isMine: message.author.id == _user.id,
                      );
                    },
                    avatarBuilder: (user) {
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            child: CachedNetworkImage(
                              imageUrl: user.imageUrl ?? '',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) {
                                String name =
                                    "${user.firstName} ${user.lastName}";
                                List<String> words =
                                    name.trim().split(RegExp(r'\s+'));
                                String initials = words
                                    .map((word) => word[0].toUpperCase())
                                    .join();
                                return PlaceholderCircle(
                                  text: initials,
                                  textColor: theme.primaryColor,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          )
                        ],
                      );
                    },
                    customMessageBuilder: (message, {messageWidth = 0}) {
                      if (message.metadata?["feedback"] != null) {
                        return RecordedCsatChatMessage(
                          theme: theme,
                          l10n: widget.l10n,
                          message: types.CustomMessage(
                              author: message.author, id: message.id),
                          maxWidth: messageWidth,
                        );
                      }
                      return CSATChatMessage(
                        theme: theme,
                        l10n: widget.l10n,
                        message: types.CustomMessage(
                            author: message.author, id: message.id),
                        maxWidth: messageWidth,
                        sendCsatResults: (rating, feedback) {
                          chatwootClient?.sendCsatSurveyResults(
                              message.metadata!['conversationUuid'],
                              rating,
                              feedback);
                        },
                      );
                    },
                    l10n: widget.l10n,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      chatwootClient?.loadMessages();
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatwootClient?.dispose();
    LinkMetadata.dispose();
  }
}

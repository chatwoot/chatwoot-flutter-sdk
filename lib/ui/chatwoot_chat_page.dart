library chatwoot_client_sdk;

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/chatwoot_client.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

class ChatwootChatPage extends StatefulWidget {
  final String baseUrl;
  final String inboxIdentifier;
  final bool enablePersisitence;
  final ChatwootUser? user;
  const ChatwootChatPage({
    Key? key,
    required this.baseUrl,
    required this.inboxIdentifier,
    this.enablePersisitence = true,
    this.user
  }) : super(key: key);

  @override
  _ChatwootChatPageState createState() => _ChatwootChatPageState();
}

class _ChatwootChatPageState extends State<ChatwootChatPage> {
  List<types.Message> _messages = [];
  final idGen = Uuid();
  late final _user;
  late final ChatwootClient chatwootClient;

  late final chatwootCallbacks;

  @override
  void initState() {
    super.initState();

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
      onWelcome: (event){},
      onPing: (event){},
      onConfirmedSubscription: (event){},
      onPersistedMessagesRetrieved: (persistedMessages){
        if(widget.enablePersisitence){
          setState(() {
            _messages = persistedMessages.map((message)=> chatwootMessageToTextMessage(message)).toList();
          });
        }
      },
      onMessagesRetrieved: (messages){
        setState(() {
          final chatMessages = messages.map((message)=> chatwootMessageToTextMessage(message)).toList();
          final mergedMessages = [..._messages,chatMessages].toSet().toList() as List<types.Message>;
          final now = DateTime.now().millisecondsSinceEpoch;
          mergedMessages.sort((a,b){
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
        });
      },
      onMessageReceived: (chatwootMessage){
        _addMessage(chatwootMessageToTextMessage(chatwootMessage));
      },
      onMessageSent: (chatwootMessage, echoId){
        _handleMessageSent(chatwootMessageToTextMessage(chatwootMessage, echoId: echoId));
      },
      onError: (event){
        print("Ooops! Something went wrong. Error Cause: ${event.cause}");
      },
    );


    ChatwootClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        callbacks: chatwootCallbacks
    ).then((client) {
      setState(() {
        chatwootClient = client;
        chatwootClient.loadMessages();
      });
    }).onError((error, stackTrace) {
      print(error);
    });

  }

  types.Message chatwootMessageToTextMessage(ChatwootMessage message, {String? echoId}){
    return types.TextMessage(
        id: echoId ?? idGen.v4(),
        author: message.isMine ? _user : types.User(
          id: message.sender["id"]?.identifier ?? idGen.v4(),
          firstName: message.sender["name"]?.name,
          imageUrl: message.sender["avatar_url"]?.avatarUrl,
        ),
        text: message.content,
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

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    chatwootClient.sendMessage(content: textMessage.text, echoId: textMessage.id);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        messages: _messages,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}


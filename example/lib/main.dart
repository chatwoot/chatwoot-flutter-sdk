import 'dart:io';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isChatVisible = false;

  @override
  void initState() {
    super.initState();
  }

  _showChatwootDialog() {
    ChatwootChatDialog.show(
      context,
      baseUrl: "https://app.chatwoot.com",
      inboxIdentifier: "*********************",
      title: "Chatwoot Support",
      user: ChatwootUser(
        identifier: "test@test.com",
        identifierHash:
            "***************************************************************",
        name: "test",
        email: "test@test.com",
      ),
    );
  }

// Webview SDK

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/chatwoot_logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text('Chatwoot Example'))
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isChatVisible = !_isChatVisible;
              });
            },
            child: Text(
                _isChatVisible ? "Hide webview widget" : "Show webview widget"),
          ),
          ElevatedButton(
            onPressed: () {
              _showChatwootDialog();
            },
            child: Text("Show Native widget"),
          ),
          Visibility(
            visible: _isChatVisible,
            child: Expanded(
              child: ChatwootWidget(
                websiteToken: "*********************",
                baseUrl: "https://app.chatwoot.com",
                user: ChatwootUser(
                  identifier: "test@test.com",
                  identifierHash:
                      "***************************************************************",
                  name: "test",
                  email: "test@test.com",
                ),
                locale: "en",
                closeWidget: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                //attachment only works on android for now
                onAttachFile: _androidFilePicker,
                onLoadStarted: () {
                  print("loading widget");
                },
                onLoadProgress: (int progress) {
                  print("loading... ${progress}");
                },
                onLoadCompleted: () {
                  print("widget loaded");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// Native SDK
  @override
  Widget builds(BuildContext context) {
    return ChatwootChat(
      baseUrl: "https://app.chatwoot.com",
      inboxIdentifier: "*********************",
      user: ChatwootUser(
        identifier: "test@test.com",
        identifierHash:
            "***************************************************************",
        name: "test",
        email: "test@test.com",
      ),
      appBar: AppBar(
        title: Text(
          "Chatwoot",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: InkWell(
          onTap: () => _showChatwootDialog(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/chatwoot_logo.png"),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      onWelcome: () {
        print("Welcome event received");
      },
      onPing: () {
        print("Ping event received");
      },
      onConfirmedSubscription: () {
        print("Confirmation event received");
      },
      onMessageDelivered: (_) {
        print("Message delivered event received");
      },
      onMessageSent: (_) {
        print("Message sent event received");
      },
      onConversationIsOffline: () {
        print("Conversation is offline event received");
      },
      onConversationIsOnline: () {
        print("Conversation is online event received");
      },
      onConversationStoppedTyping: () {
        print("Conversation stopped typing event received");
      },
      onConversationStartedTyping: () {
        print("Conversation started typing event received");
      },
    );
  }

  Future<List<String>> _androidFilePicker() async {
    final picker = image_picker.ImagePicker();
    final photo =
        await picker.pickImage(source: image_picker.ImageSource.gallery);

    if (photo == null) {
      return [];
    }

    final imageData = await photo.readAsBytes();
    final decodedImage = image.decodeImage(imageData);
    final scaledImage = image.copyResize(decodedImage, width: 500);
    final jpg = image.encodeJpg(scaledImage, quality: 90);

    final filePath = (await getTemporaryDirectory()).uri.resolve(
          './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
        );
    final file = await File.fromUri(filePath).create(recursive: true);
    await file.writeAsBytes(jpg, flush: true);

    return [file.uri.toString()];
  }
}

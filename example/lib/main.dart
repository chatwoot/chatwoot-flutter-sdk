import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _showChatwootDialog() {
    ChatwootChatDialog.show(
      context,
      baseUrl: "<<<your-chatwoot-base-url-here>>>",
      inboxIdentifier: "<<<your-inbox-identifier-here>>>",
      title: "Chatwoot Support",
      user: ChatwootUser(
        identifier: "test@test.com",
        name: "Tester test",
        email: "test@test.com",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatwootChat(
      baseUrl: "<<<your-chatwoot-base-url-here>>>",
      inboxIdentifier: "<<<your-inbox-identifier-here>>>",
      user: ChatwootUser(
        identifier: "test@test.com",
        name: "Tester test",
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
}

# Integrate Chatwoot with Flutter app

![Screenshot_chatwoot](https://user-images.githubusercontent.com/22669874/125801289-14631c60-9788-4ff6-af2b-1c27dcc030af.png)

Integrate Chatwoot flutter client into your flutter app and talk to your visitors/users in real time. [Chatwoot](https://github.com/chatwoot/chatwoot) helps you to chat with your visitors and provide exceptional support in real time. To use Chatwoot in your flutter app, follow the steps described below.

## 1. Create an Api inbox in Chatwoot

Refer to [Website Channel](https://www.chatwoot.com/docs/product/channels/live-chat/create-website-channel) document.

## 2. Add the package to your project

`flutter pub add chatwoot_client_sdk`

or

Add 
`chatwoot_client_sdk:<<version>>` 
to your project's [pubspec.yml](https://flutter.dev/docs/development/tools/pubspec) file. You can check [here](https://pub.dev/packages/chatwoot_client_sdk) for the latest version.

NB: This library uses [Hive](https://pub.dev/packages/hive) for local storage and [Flutter Chat UI](https://pub.dev/packages/flutter_chat_ui) for its user interface.

## 3. How to use
Replace `baseUrl` and `inboxIdentifier` with appropriate values. See [](https://www.chatwoot.com/docs/product/channels/api/client-apis) for more information on how to obtain your `baseUrl` and `inboxIdentifier`

### a. Using ChatwootChat Widget
Use ChatwootChat widget, for faster simpler integration with out of the box chat ui. Customize chat UI theme by passing a `ChatwootChatTheme` with your custom theme colors and more.

```
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
  Widget build(BuildContext context) {
    return ChatwootChat(
      baseUrl: "<<<your-chatwoot-base-url-here>>>",
      inboxIdentifier: "<<<your-inbox-identifier-here>>>",
      user: ChatwootUser(
        identifier: "john@gmail.com",
        name: "John Samuel",
        email: "john@gmail.com",
      ),
      appBar: AppBar(
        title: Text(
          "Chatwoot",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
      ),
      onWelcome: (){
        print("Welcome event received");
      },
      onPing: (){
        print("Ping event received");
      },
      onConfirmedSubscription: (){
        print("Confirmation event received");
      },
      onMessageDelivered: (_){
        print("Message delivered event received");
      },
      onMessageSent: (_){
        print("Message sent event received");
      },
      onConversationIsOffline: (){
        print("Conversation is offline event received");
      },
      onConversationIsOnline: (){
        print("Conversation is online event received");
      },
      onConversationStoppedTyping: (){
        print("Conversation stopped typing event received");
      },
      onConversationStartedTyping: (){
        print("Conversation started typing event received");
      },
    );
  }
}
```

Horray! You're done.

You also find a sample implementation [here](https://github.com/EphraimNetWorks/chatwoot_flutter_client/blob/main/example/lib/main.dart)

### b. Using Chatwoot Client
You can also create a customized chat ui and use `ChatwootClient` to load and sendMessages. Messaging events like `onMessageSent` and `onMessageReceived` will be triggered on `ChatwootCallback` passed when creating the client instance.

```
final chatwootCallbacks = ChatwootCallbacks(
      onWelcome: (){
        print("on welcome");
      },
      onPing: (){
        print("on ping");
      },
      onConfirmedSubscription: (){
        print("on confirmed subscription");
      },
      onConversationStartedTyping: (){
        print("on conversation started typing");
      },
      onConversationStoppedTyping: (){
        print("on conversation stopped typing");
      },
      onPersistedMessagesRetrieved: (persistedMessages){
        print("persisted messages retrieved");
      },
      onMessagesRetrieved: (messages){
        print("messages retrieved");
      },
      onMessageReceived: (chatwootMessage){
        print("message received");
      },
      onMessageDelivered: (chatwootMessage, echoId){
        print("message delivered");
      },
      onMessageSent: (chatwootMessage, echoId){
        print("message sent");
      },
      onError: (error){
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
      },
    );
    
    ChatwootClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        enablePersistence: widget.enablePersistence,
        callbacks: chatwootCallbacks
    ).then((client) {
        client.loadMessages();
    }).onError((error, stackTrace) {
      print("chatwoot client creation failed with error $error: $stackTrace");
    });
    ```







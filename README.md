[![Pub Version](https://img.shields.io/pub/v/chatwoot_sdk?color=blueviolet)](https://pub.dev/packages/chatwoot_sdk) ![build](https://github.com/EphraimNetWorks/test_cw_flutter_client/actions/workflows/develop-actions.yml/badge.svg) [![likes](https://badges.bar/chatwoot_sdk/likes)](https://pub.dev/packages/chatwoot_sdk/score) [![popularity](https://badges.bar/chatwoot_sdk/popularity)](https://pub.dev/packages/chatwoot_sdk/score) [![pub points](https://badges.bar/chatwoot_sdk/pub%20points)](https://pub.dev/packages/chatwoot_sdk/score)

# Integrate Chatwoot with Flutter app

Integrate Chatwoot flutter client into your flutter app and talk to your visitors in real time. [Chatwoot](https://github.com/chatwoot/chatwoot) helps you to chat with your visitors and provide exceptional support in real time. To use Chatwoot in your flutter app, follow the steps described below.

<img src="https://user-images.githubusercontent.com/22669874/126673917-f8bdd47a-7a4d-4241-8b46-27ef108a0e23.png" alt="chatwoot screenshot" height="560"/>

## 1. Create an Api inbox in Chatwoot

Refer to [Create API Channel](https://www.chatwoot.com/docs/product/channels/api/create-channel) document.

## 2. Add the package to your project

Run the command below in your terminal

`flutter pub add chatwoot_sdk`

or

Add
`chatwoot_sdk:<<version>>`
to your project's [pubspec.yml](https://flutter.dev/docs/development/tools/pubspec) file. You can check [here](https://pub.dev/packages/chatwoot_sdk) for the latest version.

NB: This library uses [Hive](https://pub.dev/packages/hive) for local storage and [Flutter Chat UI](https://pub.dev/packages/flutter_chat_ui) for its user interface.

## 3. How to use

Replace `baseUrl` and `inboxIdentifier` with appropriate values. See [here](https://www.chatwoot.com/docs/product/channels/api/client-apis) for more information on how to obtain your `baseUrl` and `inboxIdentifier`

### a. Using ChatwootChatDialog

Simply call `ChatwootChatDialog.show` with your parameters to show chat dialog. To close dialog use `Navigator.pop(context)`.

```
// Example
ChatwootChatDialog.show(
  context,
  baseUrl: "<<<your-chatwoot-base-url-here>>>",
  inboxIdentifier: "<<<your-inbox-identifier-here>>>",
  title: "Chatwoot Support",
  user: ChatwootUser(
    identifier: "john@gmail.com",
    name: "John Samuel",
    email: "john@gmail.com",
  ),
);
```

#### Available Parameters

| Name              | Default                   | Type         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------- | ------------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| context           | -                         | BuildContext | Current BuildContext                                                                                                                                                                                                                                                                                                                                                                                                                               |
| baseUrl           | -                         | String       | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier   | -                         | String       | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance | true                      | bool         | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| title             | -                         | String       | Title for modal                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| user              | null                      | ChatwootUser | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| primaryColor      | Color(0xff1f93ff)         | Color        | Primary color for ChatwootChatTheme                                                                                                                                                                                                                                                                                                                                                                                                                |
| secondaryColor    | Colors.white              | Color        | Secondary color for ChatwootChatTheme                                                                                                                                                                                                                                                                                                                                                                                                              |
| backgroundColor   | Color(0xfff4f6fb)         | Color        | Background color for ChatwootChatTheme                                                                                                                                                                                                                                                                                                                                                                                                             |
| l10n              | ChatwootL10n()            | ChatwootL10n | Localized strings for ChatwootChat widget.                                                                                                                                                                                                                                                                                                                                                                                                         |
| timeFormat        | DateFormat.Hm()           | DateFormat   | Date format for chats                                                                                                                                                                                                                                                                                                                                                                                                                              |
| dateFormat        | DateFormat("EEEE MMMM d") | DateFormat   | Time format for chats                                                                                                                                                                                                                                                                                                                                                                                                                              |

### b. Using ChatwootChat Widget

To embed ChatwootChat widget inside a part of your app, use the `ChatwootChat` widget. Customize chat UI theme by passing a `ChatwootChatTheme` with your custom theme colors and more.

```
import 'package:chatwoot_sdk/chatwoot_sdk.dart';
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

#### Available Parameters

| Name              | Default                   | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------- | ------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| appBar            | null                      | PreferredSizeWidget | Specify appBar if widget is being used as standalone page                                                                                                                                                                                                                                                                                                                                                                                          |
| baseUrl           | -                         | String              | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier   | -                         | String              | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance | true                      | bool                | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user              | null                      | ChatwootUser        | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| l10n              | ChatwootL10n()            | ChatwootL10n        | Localized strings for ChatwootChat widget.                                                                                                                                                                                                                                                                                                                                                                                                         |
| timeFormat        | DateFormat.Hm()           | DateFormat          | Date format for chats                                                                                                                                                                                                                                                                                                                                                                                                                              |
| dateFormat        | DateFormat("EEEE MMMM d") | DateFormat          | Time format for chats                                                                                                                                                                                                                                                                                                                                                                                                                              |
| showAvatars       | true                      | bool                | Show avatars for received messages                                                                                                                                                                                                                                                                                                                                                                                                                 |
| showUserNames     | true                      | bool                | Show user names for received messages.                                                                                                                                                                                                                                                                                                                                                                                                             |

### c. Using Chatwoot Client

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

#### Available Parameters

| Name              | Default | Type              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------- | ------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| baseUrl           | -       | String            | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier   | -       | String            | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance | true    | bool              | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user              | null    | ChatwootUser      | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| callbacks         | null    | ChatwootCallbacks | Callbacks for handling chatwoot events                                                                                                                                                                                                                                                                                                                                                                                                             |

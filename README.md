[![Pub Version](https://img.shields.io/pub/v/chatwoot_client_sdk?color=blueviolet)](https://pub.dev/packages/chatwoot_sdk)

# Integrate Chatwoot with Flutter app

Integrate Chatwoot flutter client into your flutter app and talk to your visitors in real time. [Chatwoot](https://github.com/chatwoot/chatwoot) helps you to chat with your visitors and provide exceptional support in real time. To use Chatwoot in your flutter app, follow the steps described below.

<img src="https://user-images.githubusercontent.com/22669874/225545427-bd3fe38c-d116-4286-b542-67b03a51e2d2.jpg" alt="chatwoot screenshot" height="560"/>

## 1. Add the package to your project

Run the command below in your terminal

`flutter pub add chatwoot_sdk`

or

Add
`chatwoot_sdk:<<version>>`
to your project's [pubspec.yml](https://flutter.dev/docs/development/tools/pubspec) file. You can check [here](https://pub.dev/packages/chatwoot_sdk) for the latest version.

## 2. How to use

### a. Using ChatwootWidget

* Create a website channel in chatwoot server by following the steps described here https://www.chatwoot.com/docs/channels/website
* Replace websiteToken prop and baseUrl

```dart
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatwoot Example"),
      ),
      body: ChatwootWidget(
        websiteToken: "websiteToken",
        baseUrl: "https://app.chatwoot.com",
        user: ChatwootUser(
          identifier: "test@test.com",
          name: "Tester test",
          email: "test@test.com",
        ),
        locale: "fr",
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
```

Horray! You're done.


#### Available Parameters

| Name             | Default | Type                            | Description                                                                                            |
|------------------|---------|---------------------------------|--------------------------------------------------------------------------------------------------------|
| websiteToken     | -       | String                          | Website inbox channel token                                                                            |
| baseUrl          | -       | String                          | Installation url for chatwoot                                                                          |
| user             | -       | ChatwootUser                    | User information about the user like email, username and avatar_url                                    |
| locale           | en      | String                          | User locale                                                                                            |
| closeWidget      | -       | void Function()                 | widget close event                                                                                     |
| customAttributes | -       | dynamic                         | Additional information about the customer                                                              |
| onAttachFile     | -       | Future<List<String>> Function() | Widget Attachment event. Should return a list of File Uris Currently supported only on Android devices |
| onLoadStarted    | -       | void Function()                 | Widget load start event                                                                                |
| onLoadProgress   | -       | void Function(int)              | Widget Load progress event                                                                             |
| onLoadCompleted  | -       | void Function()                 | Widget Load completed event                                                                            |

### b. Using Chatwoot Client
* Create an Api inbox in Chatwoot. Refer to [Create API Channel](https://www.chatwoot.com/docs/product/channels/api/create-channel) document.
* Create your own customized chat ui and use `ChatwootClient` to load and sendMessages. Messaging events like `onMessageSent` and `onMessageReceived` will be triggered on `ChatwootCallback` argument passed when creating the client instance.


NB: This chatwoot client uses [Hive](https://pub.dev/packages/hive) for local storage.

```dart
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
|-------------------|---------|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl           | -       | String            | Installation url for chatwoot                                                                                                                                                                                                                                                                                                                                                                                                                      |
| inboxIdentifier   | -       | String            | Identifier for target chatwoot inbox                                                                                                                                                                                                                                                                                                                                                                                                               |
| enablePersistance | true    | bool              | Enables persistence of chatwoot client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists chatwoot client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call ChatwootClient.clearData or ChatwootClient.clearAllData<br>false - holds chatwoot client instance's data in memory and is cleared as<br>soon as chatwoot client instance is disposed<br>Setting |
| user              | null    | ChatwootUser      | Custom user details to be attached to chatwoot contact                                                                                                                                                                                                                                                                                                                                                                                             |
| callbacks         | null    | ChatwootCallbacks | Callbacks for handling chatwoot events                                                                                                                                                                                                                                                                                                                                                                                                             |

import 'dart:io';

import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
        websiteToken: "YOUR_TOKEN",
        baseUrl: "https://app.chatwoot.com",
        user: ChatwootUser(
          identifier: "test@test.com",
          name: "Tester test",
          email: "test@test.com",
        ),
        locale: "en",
        closeWidget: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else {
            exit(0);
          }
        },
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


}

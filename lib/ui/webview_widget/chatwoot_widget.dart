import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/ui/webview_widget/webview.dart';
import 'package:flutter/material.dart';

///ChatwootWidget
/// {@category FlutterClientSdk}
class ChatwootWidget extends StatefulWidget {
  ///Website channel token
  final String websiteToken;

  ///Installation url for chatwoot
  final String baseUrl;

  ///User information about the user like email, username and avatar_url
  final ChatwootUser? user;

  ///User locale
  final String locale;

  ///Widget Close event
  final void Function()? closeWidget;

  ///Additional information about the customer
  final customAttributes;


  ///Widget Load started event
  final void Function()? onLoadStarted;

  ///Widget Load progress event
  final void Function(int)? onLoadProgress;

  ///Widget Load completed event
  final void Function()? onLoadCompleted;
  ChatwootWidget(
      {Key? key,
      required this.websiteToken,
      required this.baseUrl,
      this.user,
      this.locale = "en",
      this.customAttributes,
      this.closeWidget,
      this.onLoadStarted,
      this.onLoadProgress,
      this.onLoadCompleted})
      : super(key: key);

  @override
  _ChatwootWidgetState createState() => _ChatwootWidgetState();
}

class _ChatwootWidgetState extends State<ChatwootWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Webview(
      websiteToken: widget.websiteToken,
      baseUrl: widget.baseUrl,
      user: widget.user,
      locale: widget.locale,
      customAttributes: widget.customAttributes,
      closeWidget: widget.closeWidget,
      onLoadStarted: widget.onLoadStarted,
      onLoadCompleted: widget.onLoadCompleted,
      onLoadProgress: widget.onLoadProgress,
    );
  }
}

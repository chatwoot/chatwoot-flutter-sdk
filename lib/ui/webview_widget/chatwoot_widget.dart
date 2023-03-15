import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/ui/webview_widget/webview.dart';
import 'package:flutter/material.dart';

///ChatwootWidget
/// {@category FlutterClientSdk}
class ChatwootWidget extends StatefulWidget {
  final String websiteToken;
  final String baseUrl;
  final ChatwootUser? user;
  final String locale;
  final void Function()? closeWidget;
  final customAttributes;
  final Future<List<String>> Function()? onAttachFile;

  final void Function()? onLoadStarted;
  final void Function(int)? onLoadProgress;
  final void Function()? onLoadCompleted;
  ChatwootWidget(
      {Key? key,
      required this.websiteToken,
      required this.baseUrl,
      this.user,
      this.locale = "en",
      this.customAttributes,
      this.closeWidget,
      this.onAttachFile,
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
      onAttachFile: widget.onAttachFile,
      onLoadStarted: widget.onLoadStarted,
      onLoadCompleted: widget.onLoadCompleted,
      onLoadProgress: widget.onLoadProgress,
    );
  }
}

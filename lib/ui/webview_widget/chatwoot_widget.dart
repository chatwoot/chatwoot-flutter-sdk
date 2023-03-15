import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/ui/webview_widget/webview.dart';
import 'package:flutter/material.dart';

///ChatwootWidget
/// {@category FlutterClientSdk}
class ChatwootWidget extends StatefulWidget {
  final String websiteToken;
  final String baseUrl;
  final String cwCookie;
  final ChatwootUser? user;
  final String locale;
  final void Function()? closeWidget;
  final customAttributes;
  ChatwootWidget(
      {Key? key,
      required this.websiteToken,
      required this.baseUrl,
      this.cwCookie = "",
      this.user,
      this.locale = "en",
      this.customAttributes,
      this.closeWidget})
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
    return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(8.0),
        child: Webview(
          websiteToken: widget.websiteToken,
          baseUrl: widget.baseUrl,
          cwCookie: widget.cwCookie,
          user: widget.user,
          locale: widget.locale,
          customAttributes: widget.customAttributes,
        ));
  }
}

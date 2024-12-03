import 'package:chatwoot_sdk/ui/chatwoot_chat_theme.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {

  final ChatwootChatTheme theme;
  final ChatwootL10n l10n;
  final void Function(String) onMessageSent;
  final void Function() onAttachmentPressed;
  const ChatInput({Key? key, required this.theme, required this.l10n, required this.onMessageSent, required this.onAttachmentPressed}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String text = '';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    this._controller = TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.theme.inputPadding,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: widget.theme.inputBorderRadius,
          border: Border.all(
            color: _isFocused ? widget.theme.primaryColor : Colors.grey.shade300,
            width: 1.0,
          ),
          boxShadow: _isFocused
              ? [
            BoxShadow(
              color: widget.theme.primaryColor.withOpacity(0.2),
              blurRadius: 6.0,
              spreadRadius: 2.0,
            ),
          ]
              : [],
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Text Field
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.l10n.inputPlaceholder,
                  border: InputBorder.none,
                  contentPadding: widget.theme.inputPadding,
                ),
                onSubmitted: (submittedText){
                  widget.onMessageSent(submittedText);
                },
                onChanged: (newText){
                  setState(() {
                    text = newText;
                  });
                },
              ),
            ),
            // Attachment Icon
            IconButton(
              onPressed: () {
                widget.onAttachmentPressed();
              },
              icon: const Icon(
                Icons.attach_file,
                color: Colors.grey,
              ),
            ),
            // Emoji Icon
            IconButton(
              onPressed: _submit,
              icon: Icon(
                Icons.send_rounded,
                color: text.isNotEmpty ? widget.theme.primaryColor:Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  _submit(){
    if(text.isNotEmpty){
      widget.onMessageSent(text);
      text = "";
      _controller.text = "";
    }
  }
}

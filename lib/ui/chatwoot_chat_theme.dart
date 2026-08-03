import 'package:flutter/material.dart';

const CHATWOOT_COLOR_PRIMARY = Color(0xff1f93ff);
const CHATWOOT_BG_COLOR = Color(0xfff4f6fb);
const CHATWOOT_AVATAR_COLORS = [CHATWOOT_COLOR_PRIMARY];
const NEUTRAL_2 = Colors.grey;
const NEUTRAL_0 = Colors.black26;
const NEUTRAL_7 = Colors.black;
const NEUTRAL_7_WITH_OPACITY = Colors.black54;
const PRIMARY = CHATWOOT_COLOR_PRIMARY;

/// Default chatwoot chat theme
/// 
/// ⚠️ Note: This class is deprecated and not compatible with flutter_chat_ui v2.x
/// It's kept for reference but should not be used.
@immutable
class ChatwootChatTheme {
  /// Background color for the scaffold
  final Color backgroundColor;
  
  /// Creates a chatwoot chat theme. Use this constructor if you want to
  /// override only a couple of variables.
  const ChatwootChatTheme({
    this.backgroundColor = CHATWOOT_BG_COLOR,
  });
}

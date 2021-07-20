import 'package:flutter_chat_ui/flutter_chat_ui.dart';

/// Base chat l10n containing all required variables to provide localized chatwoot chat
class ChatwootL10n extends ChatL10n {
  /// Accessibility label (hint) for the attachment button
  final String attachmentButtonAccessibilityLabel;

  /// Placeholder when there are no messages
  final String emptyChatPlaceholder;

  /// Accessibility label (hint) for the tap action on file message
  final String fileButtonAccessibilityLabel;

  /// Placeholder for the text field
  final String inputPlaceholder;

  /// Placeholder for the text field
  final String onlineText;

  /// Placeholder for the text field
  final String offlineText;

  /// Placeholder for the text field
  final String typingText;

  /// Accessibility label (hint) for the send button
  final String sendButtonAccessibilityLabel;

  /// Creates a new chatwoot l10n
  const ChatwootL10n({
    this.attachmentButtonAccessibilityLabel = "",
    this.emptyChatPlaceholder = "",
    this.fileButtonAccessibilityLabel = "",
    this.onlineText = "online",
    this.offlineText = "Typically replies in a few hours",
    this.typingText = "typing...",
    this.inputPlaceholder = "Type your message",
    this.sendButtonAccessibilityLabel = "Send Message",
  }) : super(
            attachmentButtonAccessibilityLabel:
                attachmentButtonAccessibilityLabel,
            emptyChatPlaceholder: emptyChatPlaceholder,
            fileButtonAccessibilityLabel: fileButtonAccessibilityLabel,
            inputPlaceholder: inputPlaceholder,
            sendButtonAccessibilityLabel: sendButtonAccessibilityLabel);
}

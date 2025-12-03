/// Base chat l10n containing all required variables to provide localized chatwoot chat
/// 
/// ⚠️ Note: This class is deprecated and not compatible with flutter_chat_ui v2.x
/// It's kept for reference but should not be used.
class ChatwootL10n {
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

  /// Message when agent resolves conversation
  final String conversationResolvedMessage;

  /// Message when agent resolves conversation
  final String and;

  /// Message when agent resolves conversation
  final String isTyping;

  /// Message when agent resolves conversation
  final String others;

  /// Message when agent resolves conversation
  final String unreadMessagesLabel;

  /// Creates a new chatwoot l10n
  const ChatwootL10n({
    this.attachmentButtonAccessibilityLabel = "",
    this.emptyChatPlaceholder = "",
    this.fileButtonAccessibilityLabel = "",
    this.onlineText = "Typically replies in a few hours",
    this.offlineText = "We're away at the moment",
    this.typingText = "typing...",
    this.inputPlaceholder = "Type your message",
    this.sendButtonAccessibilityLabel = "Send Message",
    this.conversationResolvedMessage = "Your ticket has been marked as resolved",
    this.and = "and",
    this.isTyping = "is typing...",
    this.others = "others",
    this.unreadMessagesLabel = "Your ticket has been marked as resolved"
  });
}

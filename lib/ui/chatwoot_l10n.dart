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

  /// Message when agent resolves conversation
  final String conversationResolvedMessage;

  final String and;

  final String isTyping;

  final String others;

  /// Unread messages
  final String unreadMessagesLabel;

  /// Action text for csat form
  final String csatInquiryQuestion;

  /// CSAT option rating: 1
  final String csatVeryUnsatisfied;

  ///  CSAT option rating: 2
  final String csatUnsatisfied;

  ///  CSAT option rating: 3
  final String csatOK;

  ///  CSAT option rating: 4
  final String csatSatisfied;

  ///  CSAT option rating: 5
  final String csatVerySatisfied;

  /// CSAT form feed back text placholder
  final String csatFeedbackPlaceholder;

  /// Message displayed to user after completing csat survey
  final String csatThankYouMessage;

  /// Creates a new chatwoot l10n
  const ChatwootL10n(
      {this.attachmentButtonAccessibilityLabel = "",
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
      this.unreadMessagesLabel = "Your ticket has been marked as resolved",
        this.csatInquiryQuestion = "Rate your experience",
        this.csatVeryUnsatisfied = "Very poor",
        this.csatUnsatisfied = "Poor",
        this.csatOK = "Okay",
        this.csatSatisfied = "Good",
        this.csatVerySatisfied = "Excellent",
        this.csatFeedbackPlaceholder = "Leave your feedback (optional)...",
        this.csatThankYouMessage = "Thank you for your feedback"
    })
      : super(
            attachmentButtonAccessibilityLabel:
                attachmentButtonAccessibilityLabel,
            emptyChatPlaceholder: emptyChatPlaceholder,
            fileButtonAccessibilityLabel: fileButtonAccessibilityLabel,
            inputPlaceholder: inputPlaceholder,
            sendButtonAccessibilityLabel: sendButtonAccessibilityLabel,
            and: and,
            isTyping: isTyping,
            others: others,
            unreadMessagesLabel: unreadMessagesLabel
      );
}

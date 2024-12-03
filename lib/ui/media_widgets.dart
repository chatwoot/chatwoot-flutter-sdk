import 'package:chatwoot_sdk/data/remote/responses/csat_survey_response.dart';
import 'package:chatwoot_sdk/ui/chatwoot_chat_theme.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:chatwoot_sdk/ui/link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final String uri;
  const FullScreenMediaViewer({Key? key, required this.uri}) : super(key: key);

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 20.0,
            right: 20.0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AudioChatMessage extends StatefulWidget {
  final ChatwootChatTheme theme;
  final types.AudioMessage message;
  final bool isMine;
  const AudioChatMessage(
      {Key? key,
      required this.message,
      required this.isMine,
      required this.theme})
      : super(key: key);

  @override
  _AudioChatMessageState createState() => _AudioChatMessageState();
}

class _AudioChatMessageState extends State<AudioChatMessage> {
  void playAudio() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FullScreenMediaViewer(
                uri: widget.message.uri,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isMine
        ? widget.theme.sentMessageBodyTextStyle.color
        : widget.theme.receivedMessageBodyTextStyle.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play Button
          GestureDetector(
            onTap: playAudio,
            child: IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: activeColor,
                size: 40,
              ),
              onPressed: playAudio,
            ),
          ),
          const SizedBox(width: 10.0),
          // Progress Slider
          Expanded(
            child: Slider(
              value: 0,
              max: 0,
              activeColor: activeColor,
              inactiveColor: Colors.grey.shade400,
              onChanged: (value) {},
            ),
          ),
          // Timer
        ],
      ),
    );
  }
}

class VideoChatMessage extends StatefulWidget {
  final ChatwootChatTheme theme;
  final types.VideoMessage message;
  final bool isMine;
  final int maxWidth;
  const VideoChatMessage(
      {Key? key,
      required this.theme,
      required this.message,
      required this.isMine,
      required this.maxWidth})
      : super(key: key);

  @override
  _VideoChatMessageState createState() => _VideoChatMessageState();
}

class _VideoChatMessageState extends State<VideoChatMessage> {
  final double height = 300;
  void playVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FullScreenMediaViewer(
                uri: widget.message.uri,
              )),
    );
  }

  get previewData => widget.message.metadata?["preview"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: playVideo,
      child: Container(
        height: height,
        width: widget.maxWidth.toDouble(),
        child: Stack(
          children: [
            if (previewData != null)
              RawImage(
                image: previewData?.firstFrame?.image,
                fit: BoxFit.cover,
                width: widget.maxWidth.toDouble(),
                height: height,
              ),
            Positioned.fill(
              child: Center(
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextChatMessage extends StatefulWidget {
  final ChatwootChatTheme theme;
  final types.TextMessage message;
  final bool isMine;
  final int maxWidth;
  final void Function(types.TextMessage, types.PreviewData) onPreviewFetched;
  const TextChatMessage(
      {Key? key,
      required this.theme,
      required this.message,
      required this.isMine,
      required this.maxWidth,
      required this.onPreviewFetched})
      : super(key: key);

  @override
  _TextChatMessageState createState() => _TextChatMessageState();
}

class _TextChatMessageState extends State<TextChatMessage> {
  @override
  Widget build(BuildContext context) {
    print("link: $messageLink");
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final textColor = widget.isMine
        ? widget.theme.sentMessageBodyTextStyle.color
        : widget.theme.receivedMessageBodyTextStyle.color;
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: widget.theme.messageInsetsVertical,
          horizontal: widget.theme.messageInsetsHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (messageLink != null)
            LinkPreview(
              url: messageLink!, // This disables tap event
            ),
          if (messageLink != null) SizedBox(height: 8.0),
          if (messageLink != widget.message.text.trim())
            MarkdownBody(
                data: widget.message.text,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    launchUrl(Uri.parse(href));
                  }
                },
                styleSheet: styleSheet.copyWith(
                  code: widget.isMine
                      ? widget.theme.sentMessageBodyCodeTextStyle
                      : widget.theme.receivedMessageBodyCodeTextStyle,
                  p: widget.isMine
                      ? widget.theme.sentMessageBodyTextStyle
                      : widget.theme.receivedMessageBodyTextStyle,
                  h1: styleSheet.h1?.copyWith(color: textColor),
                  h2: styleSheet.h2?.copyWith(color: textColor),
                  h3: styleSheet.h3?.copyWith(color: textColor),
                  h4: styleSheet.h4?.copyWith(color: textColor),
                  h5: styleSheet.h5?.copyWith(color: textColor),
                  h6: styleSheet.h6?.copyWith(color: textColor),
                  tableBody: styleSheet.tableBody?.copyWith(color: textColor),
                  tableHead: styleSheet.tableHead?.copyWith(color: textColor),
                  a: widget.isMine
                      ? styleSheet.a?.copyWith(color: Colors.white)
                      : styleSheet.a
                          ?.copyWith(color: widget.theme.primaryColor),
                )),
          if (widget.message.metadata?["sentAt"] != null)
            Text(
              widget.message.metadata!["sentAt"],
              style: (widget.isMine
                      ? widget.theme.sentMessageBodyTextStyle
                      : widget.theme.receivedMessageBodyTextStyle
                          .copyWith(color: Colors.grey))
                  .copyWith(fontSize: 12),
            )
        ],
      ),
    );
  }

  String? get messageLink {
    // Regular expression to match URLs
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/[^\s]+)', // Match http or https URLs
      caseSensitive: false,
    );

    // Find the first match
    final Match? match = urlRegex.firstMatch(widget.message.text);

    // If a match is found, return the matched string; otherwise, return null
    return match != null ? match.group(0) : null;
  }
}

class CSATChatMessage extends StatefulWidget {
  final ChatwootChatTheme theme;
  final ChatwootL10n l10n;
  final types.CustomMessage message;
  final int maxWidth;
  final void Function(int, String) sendCsatResults;
  const CSATChatMessage(
      {Key? key,
      required this.theme,
      required this.message,
      required this.l10n,
      required this.maxWidth,
      required this.sendCsatResults})
      : super(key: key);

  @override
  _CSATChatMessageState createState() => _CSATChatMessageState();
}

class _CSATChatMessageState extends State<CSATChatMessage> {
  String? selectedOption;
  String? feedback;
  bool isSentTapped = false;
  late List<String> options;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    options = [
      widget.l10n.csatVeryUnsatisfied,
      widget.l10n.csatUnsatisfied,
      widget.l10n.csatOK,
      widget.l10n.csatSatisfied,
      widget.l10n.csatVerySatisfied,
    ];
    super.initState();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.maxWidth.toDouble(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            widget.l10n.csatInquiryQuestion,
            style: widget.theme.receivedMessageBodyBoldTextStyle,
          ),
          const SizedBox(height: 16.0),

          // Options
          Column(
            children: options.map((option) {
              return GestureDetector(
                onTap: isSentTapped
                    ? null
                    : () {
                        setState(() {
                          selectedOption = option;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: selectedOption == option
                        ? widget.theme.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: selectedOption == option
                          ? widget.theme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedOption == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selectedOption == option
                            ? widget.theme.primaryColor
                            : Colors.black,
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),

          // Feedback Field
          Container(
            color: Colors.white,
            child: TextField(
              controller: feedbackController,
              maxLines: 3,
              minLines: 3,
              enabled: !isSentTapped,
              decoration: InputDecoration(
                hintText: widget.l10n.csatFeedbackPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
              ),
              onChanged: (text) {
                feedback = text;
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Send Button
          if (!isSentTapped)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () {
                        // Handle submission
                        final rating =
                            options.indexWhere((e) => e == selectedOption) + 1;
                        widget.sendCsatResults(rating, feedback ?? '');
                        setState(() {
                          isSentTapped = true;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: selectedOption == null
                      ? Colors.grey
                      : widget.theme.primaryColor, // Disabled button styling
                ),
                child: Text(
                  "Send",
                  style: widget.theme.sentMessageBodyTextStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RecordedCsatChatMessage extends StatelessWidget {
  final ChatwootChatTheme theme;
  final ChatwootL10n l10n;
  final types.CustomMessage message;
  final int maxWidth;
  List<String> get options => [
        l10n.csatVeryUnsatisfied,
        l10n.csatUnsatisfied,
        l10n.csatOK,
        l10n.csatSatisfied,
        l10n.csatVerySatisfied,
      ];
  CsatSurveyFeedbackResponse get feedback =>
      message.metadata!["feedback"]! as CsatSurveyFeedbackResponse;
  String get selectedOption =>
      options[(feedback.csatSurveyResponse?.rating ?? 3) - 1];
  String get feedBackText => feedback.csatSurveyResponse?.feedbackMessage ?? '';

  RecordedCsatChatMessage({
    Key? key,
    required this.theme,
    required this.message,
    required this.l10n,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth.toDouble(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            l10n.csatThankYouMessage,
            style: theme.receivedMessageBodyBoldTextStyle,
          ),
          const SizedBox(height: 16.0),

          // Options
          Column(
            children: options.map((option) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: selectedOption == option
                      ? theme.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: selectedOption == option
                        ? theme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedOption == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selectedOption == option
                          ? theme.primaryColor
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: selectedOption == option
                            ? theme.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),

          // Feedback Field
          Text(
            feedBackText,
            style: theme.receivedMessageBodyTextStyle,
          ),
        ],
      ),
    );
  }
}

class PlaceholderCircle extends StatelessWidget {
  final String text;
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? textStyle;

  const PlaceholderCircle({
    Key? key,
    required this.text,
    this.size = 30.0,
    this.backgroundColor = Colors.white,
    this.textColor = CHATWOOT_COLOR_PRIMARY,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: textStyle ??
            TextStyle(
              color: textColor,
              fontSize:
                  size / 2.5, // Scales font size relative to the widget size
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

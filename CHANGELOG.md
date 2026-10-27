## [0.1.0] - Unreleased

- Migrate the website widget to InAppWebView for native attachment selection.
- Queue widget messages until the native JavaScript bridge is ready.
- Preserve quoted, multiline and Unicode customer details when configuring the widget.
- Require an explicit website token before the example connects to an instance.
- Keep the initial iOS widget load in the WebView instead of opening Safari.
- Include generated library sources in the published package.
- Require Dart 3.9 / Flutter 3.35, Android API 23+ (or Flutter's higher minimum),
  Java 17, and iOS 13+. CI uses Flutter 3.44.8.
- Replace Hive with Hive CE while preserving the existing adapter IDs.
- Remove the deprecated native chat UI classes and the `onAttachFile` callback.
  See the README migration notes before upgrading.

## [0.0.1] - Jul 15,2021

- Setup initial client sdk flow

## [0.0.2] - Jul 15,2021

- Updated example

## [0.0.3] - Jul 15,2021

- Fixed multiple Hive adapter registration issue
- Fixed theme background issue
- Resolved pub analysis issues

## [0.0.4] - Jul 15,2021

- Updated build_runner dependency to null safety version

## [0.0.5] - Jul 20,2021

- Added ChatwootChatModal
- Updated README.md

## [0.0.6] - Jul 20,2021

- Fixed received message widget overflow on mobile screens

## [0.0.7] - Jul 22,2021

- Fixed ChatwootChatDialog avatar color
- Fixed ChatwootChatDialog chat bubble overflow

## [0.0.8] - Jul 22,2021

- Update dependencies

## [0.0.9] - Jul 22,2021

- Fixed message sending issues
- Adds development docs

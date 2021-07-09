

class ChatwootParameters{
  bool isPersistenceEnabled;
  String baseUrl;
  String inboxIdentifier;
  String? userIdentifier;

  ChatwootParameters({
    required this.isPersistenceEnabled,
    required this.baseUrl,
    required this.inboxIdentifier,
    this.userIdentifier
  });
}
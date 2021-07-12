

class ChatwootParameters{
  bool isPersistenceEnabled;
  String baseUrl;
  String clientInstanceKey;
  String inboxIdentifier;
  String? userIdentifier;

  ChatwootParameters({
    required this.isPersistenceEnabled,
    required this.baseUrl,
    required this.inboxIdentifier,
    required this.clientInstanceKey,
    this.userIdentifier
  });
}
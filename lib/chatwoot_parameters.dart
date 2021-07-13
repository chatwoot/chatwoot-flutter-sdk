

import 'package:equatable/equatable.dart';

class ChatwootParameters extends Equatable{
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

  @override
  List<Object?> get props => [
    isPersistenceEnabled,
    baseUrl,
    clientInstanceKey,
    inboxIdentifier,
    userIdentifier
  ];
}
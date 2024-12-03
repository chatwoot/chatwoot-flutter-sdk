import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';

class ChatwootParameters extends Equatable {
  final bool isPersistenceEnabled;
  final String baseUrl;
  final String clientInstanceKey;
  final String inboxIdentifier;
  final String? userIdentityValidationKey;

  ChatwootParameters(
      {required this.isPersistenceEnabled,
      required this.baseUrl,
      required this.inboxIdentifier,
      required this.clientInstanceKey,
      this.userIdentityValidationKey});


  String generateHmacHash(String key, String userIdentifier) {
    // Convert the key and message to bytes
    final keyBytes = utf8.encode(key);
    final messageBytes = utf8.encode(userIdentifier);

    // Create the HMAC using SHA256
    final hmac = Hmac(sha256, keyBytes);

    final digest = hmac.convert(messageBytes);

    return digest.toString();
  }

  @override
  List<Object?> get props => [
        isPersistenceEnabled,
        baseUrl,
        clientInstanceKey,
        inboxIdentifier,
        userIdentityValidationKey
      ];
}

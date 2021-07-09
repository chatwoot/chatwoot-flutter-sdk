

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/persistence_parameters.dart';

class RepositoryParameters{
  ChatwootParameters params;
  ChatwootCallbacks callbacks;

  RepositoryParameters({
    required this.params,
    required this.callbacks
  });
}
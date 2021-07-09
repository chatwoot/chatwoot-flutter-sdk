

import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_client_sdk/di/persistence_parameters.dart';

class RepositoryParameters{
  ChatwootParameters params;
  ChatwootCallbacks callbacks;

  RepositoryParameters({
    required this.params,
    required this.callbacks
  });
}
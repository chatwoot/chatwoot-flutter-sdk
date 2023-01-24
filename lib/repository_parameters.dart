import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/chatwoot_parameters.dart';
import 'package:chatwoot_sdk/di/modules.dart';

/// Represent all needed parameters necessary for [chatwootRepositoryProvider] to successfully provide an instance
/// of [ChatwootRepository].
class RepositoryParameters {
  /// See [ChatwootParameters]
  ChatwootParameters params;

  /// See [ChatwootCallbacks]
  ChatwootCallbacks callbacks;

  RepositoryParameters({required this.params, required this.callbacks});
}

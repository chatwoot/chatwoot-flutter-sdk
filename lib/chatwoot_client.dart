
import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/di/modules.dart';
import 'package:chatwoot_client_sdk/di/persistence_parameters.dart';
import 'package:chatwoot_client_sdk/di/repository_parameters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

class ChatwootClient{

  late final ChatwootRepository repository;
  final ChatwootParameters parameters;
  final ChatwootCallbacks? callbacks;
  final container = ProviderContainer();

  ChatwootClient._({
    required this.parameters,
    this.callbacks
  }){
    repository = container.read(
        chatwootRepositoryProvider(
            RepositoryParameters(
                params: parameters,
                callbacks: callbacks ?? ChatwootCallbacks()
            )
        )
    );
  }

  static Future<ChatwootClient> create({
    required String baseUrl,
    required String inboxIdentifier,
    ChatwootUser? user,
    bool enableMessagesPersistence = false,
    ChatwootCallbacks? chatwootCallbacks
  }) async {

    final chatwootParams = ChatwootParameters(
        isPersistenceEnabled: enableMessagesPersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: user?.identifier
    );

    final client = ChatwootClient._(
        parameters: chatwootParams,
        callbacks: chatwootCallbacks
    );

    if(enableMessagesPersistence){
      await Hive.initFlutter();
    }

    return client;
  }

  dispose(){
    container.dispose();
    repository.dispose();
  }


}
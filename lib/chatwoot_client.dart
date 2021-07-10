
import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_client_sdk/di/modules.dart';
import 'package:chatwoot_client_sdk/persistence_parameters.dart';
import 'package:chatwoot_client_sdk/repository_parameters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

import 'data/local/entity/chatwoot_contact.dart';


/// Represents a chatwoot client instance
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
class ChatwootClient{

  late final ChatwootRepository _repository;
  final ChatwootParameters _parameters;
  final ChatwootCallbacks? callbacks;
  final ChatwootUser? user;
  final _container = ProviderContainer();

  String get baseUrl => _parameters.baseUrl;

  String get inboxIdentifier => _parameters.inboxIdentifier;


  ChatwootClient._(
    this._parameters,{
    this.user,
    this.callbacks
  }){
    _repository = _container.read(
        chatwootRepositoryProvider(
            RepositoryParameters(
                params: _parameters,
                callbacks: callbacks ?? ChatwootCallbacks()
            )
        )
    );
  }

  Future<void> _init() async{
    await _repository.initialize(user);
  }

  static Future<ChatwootClient> create({
    required String baseUrl,
    required String inboxIdentifier,
    ChatwootUser? user,
    bool enableMessagesPersistence = false,
    ChatwootCallbacks? callbacks
  }) async {

    if(enableMessagesPersistence){
      Hive
        ..initFlutter()
        ..registerAdapter(ChatwootContactAdapter())
        ..registerAdapter(ChatwootConversationAdapter())
        ..registerAdapter(ChatwootMessageAdapter())
        ..registerAdapter(ChatwootUserAdapter());
    }

    final chatwootParams = ChatwootParameters(
        clientInstanceKey: _getClientInstanceKey(baseUrl: baseUrl, inboxIdentifier: inboxIdentifier),
        isPersistenceEnabled: enableMessagesPersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: user?.identifier
    );

    final client = ChatwootClient._(
        chatwootParams,
        callbacks: callbacks,
        user: user
    );

    await client._init();

    return client;
  }

  void loadMessages() async{
    _repository.getPersistedMessages();
    await _repository.getMessages();
  }

  Future<void> sendMessage({
    required String content,
    required String echoId
  }) async{
    final request = ChatwootNewMessageRequest(
      content: content,
      echoId: echoId
    );
    await _repository.sendMessage(request);
  }

  static final keySeparator= "|||";
  static String _getClientInstanceKey({
    required String baseUrl,
    required String inboxIdentifier,
    String? userIdentifier
  }){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier";
  }

  static Future<void> clearData() async{
    final providerContainer = ProviderContainer();
    final params = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: ""
    );

    final localStorage = providerContainer.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    providerContainer.dispose();
  }

  dispose(){
    _repository.dispose();
    _container.dispose();
  }


}

import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_action.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_client_sdk/di/modules.dart';
import 'package:chatwoot_client_sdk/chatwoot_parameters.dart';
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

  String get baseUrl => _parameters.baseUrl;

  String get inboxIdentifier => _parameters.inboxIdentifier;


  ChatwootClient._(
    this._parameters,{
    this.user,
    this.callbacks
  }){
    providerContainerMap.putIfAbsent(_parameters.clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository = container.read(
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

  Future<void> sendAction(ChatwootActionType action) async{
    _repository.sendAction(action);
  }


  dispose(){
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository.dispose();
    container.dispose();
    providerContainerMap.remove(_parameters.clientInstanceKey);
  }

  clearClientData(){
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    localStorage.clear(clearChatwootUserStorage: false);
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
        clientInstanceKey: getClientInstanceKey(baseUrl: baseUrl, inboxIdentifier: inboxIdentifier, userIdentifier: user?.identifier),
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

  static final keySeparator= "|||";
  static String getClientInstanceKey({
    required String baseUrl,
    required String inboxIdentifier,
    String? userIdentifier
  }){
    return "$baseUrl$keySeparator$userIdentifier$keySeparator$inboxIdentifier";
  }

  static Map<String, ProviderContainer> providerContainerMap = Map();

  static Future<void> clearData({
    required String baseUrl,
    required String inboxIdentifier,
    String? userIdentifier
  }) async{

    final clientInstanceKey = getClientInstanceKey(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: userIdentifier
    );
    providerContainerMap.putIfAbsent(clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[clientInstanceKey]!;
    final params = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: ""
    );

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove(clientInstanceKey);
  }

  static Future<void> clearAllData() async{
    providerContainerMap.putIfAbsent("all", () => ProviderContainer());
    final container = providerContainerMap["all"]!;
    final params = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: ""
    );

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clearAll();

    localStorage.dispose();
    container.dispose();
  }


}
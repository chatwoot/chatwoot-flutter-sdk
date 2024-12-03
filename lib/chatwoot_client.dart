import 'package:chatwoot_sdk/chatwoot_sdk.dart';
import 'package:chatwoot_sdk/data/chatwoot_repository.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_action_data.dart';
import 'package:chatwoot_sdk/data/remote/requests/chatwoot_new_message_request.dart';
import 'package:chatwoot_sdk/data/remote/requests/send_csat_survey_request.dart';
import 'package:chatwoot_sdk/di/modules.dart';
import 'package:chatwoot_sdk/chatwoot_parameters.dart';
import 'package:chatwoot_sdk/repository_parameters.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

import 'data/local/local_storage.dart';

/// Represents a chatwoot client instance. All chatwoot operations (Example: sendMessages) are
/// passed through chatwoot client. For more info visit
/// https://www.chatwoot.com/docs/product/channels/api/client-apis
///
/// {@category FlutterClientSdk}
class ChatwootClient {
  late final ChatwootRepository _repository;
  final ChatwootParameters _parameters;
  final ChatwootCallbacks? callbacks;
  final ChatwootUser? user;

  String get baseUrl => _parameters.baseUrl;

  String get inboxIdentifier => _parameters.inboxIdentifier;

  ChatwootClient._(this._parameters, {this.user, this.callbacks}) {
    providerContainerMap.putIfAbsent(
        _parameters.clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository = container.read(chatwootRepositoryProvider(
        RepositoryParameters(
            params: _parameters, callbacks: callbacks ?? ChatwootCallbacks())));
  }

  void _init() {
    try {
      _repository.initialize(user);
    } on ChatwootClientException catch (e) {
      callbacks?.onError?.call(e);
    }
  }

  ///Retrieves chatwoot client's messages. If persistence is enabled [ChatwootCallbacks.onPersistedMessagesRetrieved]
  ///will be triggered with persisted messages. On successfully fetch from remote server
  ///[ChatwootCallbacks.onMessagesRetrieved] will be triggered
  void loadMessages() async {
    _repository.getPersistedMessages();
    await _repository.getMessages();
  }

  /// Sends chatwoot message. The echoId is your temporary message id. When message sends successfully
  /// [ChatwootMessage] will be returned with the [echoId] on [ChatwootCallbacks.onMessageSent]. If
  /// message fails to send [ChatwootCallbacks.onError] will be triggered [echoId] as data.
  Future<void> sendMessage(
      {required String content, required String echoId, List<FileAttachment>? attachment}) async {
    final request = ChatwootNewMessageRequest(content: content, echoId: echoId, attachments: attachment ?? []);
    await _repository.sendMessage(request);
  }

  ///Send chatwoot action performed by user.
  ///
  /// Example: User started typing
  Future<void> sendAction(ChatwootActionType action) async {
    _repository.sendAction(action);
  }

  ///Send chatwoot csat survey results.
  Future<void> sendCsatSurveyResults(String conversationUuid, int rating, String feedback) async {
    _repository.sendCsatFeedBack(conversationUuid, SendCsatSurveyRequest(rating: rating, feedbackMessage: feedback));
  }

  ///Disposes chatwoot client and cancels all stream subscriptions
  dispose() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository.dispose();
    container.dispose();
    providerContainerMap.remove(_parameters.clientInstanceKey);
  }

  /// Clears all chatwoot client data
  clearClientData() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    localStorage.clear(clearChatwootUserStorage: false);
  }

  /// Creates an instance of [ChatwootClient] with the [baseUrl] of your chatwoot installation,
  /// [inboxIdentifier] for the targeted inbox. Specify custom user details using [user] and [callbacks] for
  /// handling chatwoot events. By default persistence is enabled, to disable persistence set [enablePersistence] as false
  static Future<ChatwootClient> create(
      {required String baseUrl,
        required String inboxIdentifier,
        String? userIdentityValidationKey,
      ChatwootUser? user,
      bool enablePersistence = true,
      ChatwootCallbacks? callbacks}) async {
    if (enablePersistence) {
      await LocalStorage.openDB();
    }

    final chatwootParams = ChatwootParameters(
        clientInstanceKey: getClientInstanceKey(
            baseUrl: baseUrl,
            inboxIdentifier: inboxIdentifier,
            userIdentifier: user?.identifier),
        isPersistenceEnabled: enablePersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentityValidationKey: userIdentityValidationKey);

    ChatwootUser? chatUser = user;
    if(userIdentityValidationKey != null && user != null ){
      final userIdentifier = user.identifier ?? user.email ?? Uuid().v4();
      final identifierHash = chatwootParams.generateHmacHash(userIdentityValidationKey, userIdentifier);
      chatUser = ChatwootUser(
        identifier: userIdentifier,
        identifierHash: identifierHash,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        customAttributes: user.customAttributes
      );
    }

    final client =
        ChatwootClient._(
            chatwootParams,
            callbacks: callbacks,
            user: chatUser
        );

    client._init();

    return client;
  }

  static final _keySeparator = "|||";

  ///Create a chatwoot client instance key using the chatwoot client instance baseurl, inboxIdentifier
  ///and userIdentifier. Client instance keys are used to differentiate between client instances and their data
  ///(contact ([ChatwootContact]),conversation ([ChatwootConversation]) and messages ([ChatwootMessage]))
  ///
  /// Create separate [ChatwootClient] instances with same baseUrl, inboxIdentifier, userIdentifier and persistence
  /// enabled will be regarded as same therefore use same contact and conversation.
  static String getClientInstanceKey(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) {
    return "$baseUrl$_keySeparator$userIdentifier$_keySeparator$inboxIdentifier";
  }

  static Map<String, ProviderContainer> providerContainerMap = Map();

  ///Clears all persisted chatwoot data on device for a particular chatwoot client instance.
  ///See [getClientInstanceKey] on how chatwoot client instance are differentiated
  static Future<void> clearData(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) async {
    final clientInstanceKey = getClientInstanceKey(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: userIdentifier);
    providerContainerMap.putIfAbsent(
        clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[clientInstanceKey]!;
    final params = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove(clientInstanceKey);
  }

  /// Clears all persisted chatwoot data on device.
  static Future<void> clearAllData() async {
    providerContainerMap.putIfAbsent("all", () => ProviderContainer());
    final container = providerContainerMap["all"]!;
    final params = ChatwootParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clearAll();

    localStorage.dispose();
    container.dispose();
  }
}

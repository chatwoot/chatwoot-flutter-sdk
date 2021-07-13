
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_auth_service.dart';
import 'package:dio/dio.dart';


///Intercepts network requests and attaches inbox identifier, contact identifiers, conversation identifiers
///
/// Creates a new contact and conversation when no persisted contact is found
/// Clears and recreates contact when a 401 (Unauthorized) response is returned from chatwoot api
class ChatwootClientApiInterceptor extends Interceptor{
  static const INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER = "{INBOX_IDENTIFIER}";
  static const INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER = "{CONTACT_IDENTIFIER}";
  static const INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER = "{CONVERSATION_IDENTIFIER}";

  final String _inboxIdentifier;
  final LocalStorage _localStorage;
  final ChatwootClientAuthService _authService;

  ChatwootClientApiInterceptor(
    this._inboxIdentifier,
    this._localStorage, 
    this._authService
  );

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    RequestOptions newOptions = options;
    ChatwootContact? contact =  _localStorage.contactDao.getContact();
    ChatwootConversation? conversation = _localStorage.conversationDao.getConversation();

    if(contact == null){
      // create new contact from user if no token found
      contact = await _authService.createNewContact(_inboxIdentifier, _localStorage.userDao.getUser());
      conversation = await _authService.createNewConversation(_inboxIdentifier,contact.contactIdentifier!);
      await _localStorage.conversationDao.saveConversation(conversation);
      await _localStorage.contactDao.saveContact(contact);
    }

    if(conversation == null){
      conversation = await _authService.createNewConversation(_inboxIdentifier,contact.contactIdentifier!);
      await _localStorage.conversationDao.saveConversation(conversation);
    }


    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER, _inboxIdentifier);
    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER, contact.contactIdentifier!);
    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER, "${conversation.id}");

    handler.next(newOptions);

  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async{
    if(response.statusCode == 401){
      await _localStorage.clear();

      // create new contact from user if unauthorized
      final contact = await _authService.createNewContact(_inboxIdentifier, _localStorage.userDao.getUser());
      final conversation = await _authService.createNewConversation(_inboxIdentifier,contact.contactIdentifier!);
      await _localStorage.contactDao.saveContact(contact);
      await _localStorage.conversationDao.saveConversation(conversation);

      RequestOptions newOptions = response.requestOptions;
      newOptions.headers.update("AUTHORIZATION", (value) => contact.pubsubToken, ifAbsent: () => contact.pubsubToken);

      handler.next(await _authService.dio.fetch(newOptions));

    }else{
      handler.next(response);
    }
  }

}

extension Range on num {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }
}
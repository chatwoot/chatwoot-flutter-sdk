
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
import 'package:chatwoot_client_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:dio/dio.dart';


///Intercepts network requests and attaches inbox identifier, contact identifiers, conversation identifiers
///
/// Creates a new contact and conversation when no persisted contact is found
/// Clears and recreates contact when a 401 (Unauthorized) response is returned from chatwoot api
class ChatwootClientApiInterceptor extends Interceptor{
  static const INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER = "{INBOX_IDENTIFIER}";
  static const INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER = "{CONTACT_IDENTIFIER}";
  static const INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER = "{CONVERSATION_IDENTIFIER}";
  static const INTERCEPTOR_AUTHORIZATION_PLACEHOLDER = "{AUTHORIZATION}";

  final String baseUrl;
  final String inboxIdentifier;
  final LocalStorage localStorage;
  final Dio dio;

  ChatwootClientApiInterceptor({
    required this.baseUrl,
    required this.inboxIdentifier,
    required this.localStorage,
    required this.dio
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    RequestOptions newOptions = options;
    ChatwootContact? contact =  localStorage.contactDao.getContact();
    String? token = contact?.pubsubToken;
    ChatwootConversation? conversation = localStorage.conversationDao.getConversation();

    if(contact == null){
      // create new contact from user if no token found
      contact = await _createNewContact();
      conversation = await _createNewConversation(contact.contactIdentifier);
      await localStorage.conversationDao.saveConversation(conversation);
      await localStorage.contactDao.saveContact(contact);
      token = contact.pubsubToken;
    }

    if(conversation == null){
      final conversation = await _createNewConversation(contact.contactIdentifier);
      await localStorage.conversationDao.saveConversation(conversation);
    }

    if(newOptions.headers["AUTHORIZATION"] == INTERCEPTOR_AUTHORIZATION_PLACEHOLDER){
      newOptions.headers.update("AUTHORIZATION", (value) => token);
    }
    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER, inboxIdentifier);
    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER, contact.contactIdentifier);
    newOptions.path = newOptions.path.replaceAll(INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER, "${conversation!.id}");


  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async{
    if(response.statusCode == 401){
      await localStorage.clear();

      // create new contact from user if unauthorized
      final contact = await _createNewContact();
      final conversation = await _createNewConversation(contact.contactIdentifier);
      await localStorage.contactDao.saveContact(contact);
      await localStorage.conversationDao.saveConversation(conversation);

      RequestOptions newOptions = response.requestOptions;
      newOptions.headers.update("AUTHORIZATION", (value) => contact.pubsubToken);

      handler.next(await dio.fetch(newOptions));

    }else{
      handler.next(response);
    }
  }

  Future<ChatwootContact> _createNewContact() async{
    try{
      final createResponse = await dio.post(
          "public/api/v1/inboxes/$inboxIdentifier/contacts",
          data: localStorage.userDao.getUser()
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        //creating contact successful continue with request
        final contact = ChatwootContact.fromJson(createResponse.data);
        await localStorage.contactDao.saveContact(contact);
        return contact;
      }else{
        throw ChatwootClientException(
            createResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.CREATE_CONTACT_FAILED
        );
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message,ChatwootClientExceptionType.CREATE_CONTACT_FAILED);
    }
  }

  Future<ChatwootConversation> _createNewConversation(String contactIdentifier) async{
    try{
      final createResponse = await dio.post(
          "public/api/v1/inboxes/$inboxIdentifier/contacts/$contactIdentifier/conversations"
      );
      if((createResponse.statusCode ?? 0).isBetween(199, 300) ){
        //creating contact successful continue with request
        final newConversation = ChatwootConversation.fromJson(createResponse.data);
        await localStorage.conversationDao.saveConversation(newConversation);
        return newConversation;
      }else{
        throw ChatwootClientException(
            createResponse.statusMessage ?? "unknown error",
            ChatwootClientExceptionType.CREATE_CONVERSATION_FAILED
        );
      }
    } on DioError catch(e){
      throw ChatwootClientException(e.message, ChatwootClientExceptionType.CREATE_CONVERSATION_FAILED);
    }
  }
}

extension Range on num {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }
}
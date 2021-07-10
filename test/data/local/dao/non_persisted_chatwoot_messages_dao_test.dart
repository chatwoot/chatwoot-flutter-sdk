import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("Non Persisted Chatwoot Messages Dao Test", (){
    late NonPersistedChatwootMessagesDao dao ;
    final testMessage = ChatwootMessage(
        id: "id",
        content: "content",
        messageType: "messageType",
        contentType: "contentType",
        contentAttributes: "contentAttributes",
        createdAt: DateTime.now().toString(),
        conversationId: "conversationId",
        attachments: [],
        sender: "sender"
    );

    setUp((){
      dao = NonPersistedChatwootMessagesDao();
    });

    test('Given message is successfully deleted when deleteMessage is called, then getMessage should return null', () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.deleteMessage(testMessage.id);

      //THEN
      expect(dao.getMessage(testMessage.id), null);
    });

    test('Given message is successfully saved when saveMessage is called, then getMessage should return saved message', () {

      //WHEN
      dao.saveMessage(testMessage);

      //THEN
      expect(dao.getMessage(testMessage.id), testMessage);
    });

    test('Given messages are successfully saved when saveMessages is called, then getMessages should return saved messages', () {

      final messages = [testMessage];

      //WHEN
      dao.saveAllMessages(messages);

      //THEN
      expect(dao.getMessages(), messages);
    });

    test('Given message is successfully retrieved when getMessage is called, then retrieved message should not be null', () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessage = dao.getMessage(testMessage.id);

      //THEN
      expect(retrievedMessage, testMessage);
    });

    test('Given messages exist in database when getMessages is called, then retrieved messages should not be empty', () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 1);
      expect(retrievedMessages[0], testMessage);
    });

    test('Given messages do not exist in database when getMessages is called, then retrieved messages should be empty', () {
      //GIVEN
      dao.clear();

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 0);
    });

    test('Given messages are successfully cleared when clear is called, then no message should exist in database', () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.clear();

      //THEN
      final retrievedMessages = dao.getMessages();
      expect(retrievedMessages.length, 0);
    });

    test('Given dao is successfully disposed when onDispose is called, then saved message should be null', () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedMessage = dao.getMessage(testMessage.id);
      expect(retrievedMessage, null);
    });
  });
}
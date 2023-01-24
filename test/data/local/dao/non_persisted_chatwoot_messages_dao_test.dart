import 'package:chatwoot_sdk/data/local/dao/chatwoot_messages_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Non Persisted Chatwoot Messages Dao Test", () {
    late NonPersistedChatwootMessagesDao dao;
    late final ChatwootMessage testMessage;

    setUpAll(() async {
      testMessage = ChatwootMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"));
      dao = NonPersistedChatwootMessagesDao();
    });

    test(
        'Given message is successfully deleted when deleteMessage is called, then getMessage should return null',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.deleteMessage(testMessage.id);

      //THEN
      expect(dao.getMessage(testMessage.id), null);
    });

    test(
        'Given message is successfully saved when saveMessage is called, then getMessage should return saved message',
        () {
      //WHEN
      dao.saveMessage(testMessage);

      //THEN
      expect(dao.getMessage(testMessage.id), testMessage);
    });

    test(
        'Given messages are successfully saved when saveMessages is called, then getMessages should return saved messages',
        () {
      final messages = [testMessage];

      //WHEN
      dao.saveAllMessages(messages);

      //THEN
      expect(dao.getMessages(), messages);
    });

    test(
        'Given message is successfully retrieved when getMessage is called, then retrieved message should not be null',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessage = dao.getMessage(testMessage.id);

      //THEN
      expect(retrievedMessage, testMessage);
    });

    test(
        'Given messages exist in database when getMessages is called, then retrieved messages should not be empty',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 1);
      expect(retrievedMessages[0], testMessage);
    });

    test(
        'Given messages do not exist in database when getMessages is called, then retrieved messages should be empty',
        () {
      //GIVEN
      dao.clear();

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 0);
    });

    test(
        'Given messages are successfully cleared when clear is called, then no message should exist in database',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.clear();

      //THEN
      final retrievedMessages = dao.getMessages();
      expect(retrievedMessages.length, 0);
    });

    test(
        'Given messages are successfully cleared when clearAll is called, then retrieving messages should be empty',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.clearAll();

      //THEN
      expect(dao.getMessages().isEmpty, true);
    });

    test(
        'Given dao is successfully disposed when onDispose is called, then saved message should be null',
        () {
      //GIVEN
      dao.saveMessage(testMessage);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedMessage = dao.getMessage(testMessage.id);
      expect(retrievedMessage, null);
    });

    tearDown(() {
      dao.clearAll();
    });
  });
}

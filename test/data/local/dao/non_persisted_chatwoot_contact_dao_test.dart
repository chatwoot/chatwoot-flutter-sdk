import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Non Persisted Chatwoot Contact Dao Test", () {
    late NonPersistedChatwootContactDao dao;
    late final ChatwootContact testContact;

    setUpAll(() async {
      testContact = ChatwootContact.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "contact"));
      dao = NonPersistedChatwootContactDao();
    });

    test(
        'Given contact is successfully deleted when deleteContact is called, then getContact should return null',
        () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      dao.deleteContact();

      //THEN
      expect(dao.getContact(), null);
    });

    test(
        'Given contact is successfully save when saveContact is called, then getContact should return saved contact',
        () {
      //WHEN
      dao.saveContact(testContact);

      //THEN
      expect(dao.getContact(), testContact);
    });

    test(
        'Given contact is successfully retrieved when getContact is called, then retrieved contact should not be null',
        () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      final retrievedContact = dao.getContact();

      //THEN
      expect(retrievedContact, testContact);
    });

    test(
        'Given contacts are successfully cleared when clearAll is called, then retrieving a contact should be null',
        () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      dao.clearAll();

      //THEN
      expect(dao.getContact(), null);
    });

    test(
        'Given dao is successfully disposed when onDispose is called, then saved contact should be null',
        () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedContact = dao.getContact();
      expect(retrievedContact, null);
    });

    tearDown(() {
      dao.clearAll();
    });
  });
}

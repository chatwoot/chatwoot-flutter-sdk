import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Non Persisted Chatwoot Contact Dao Test", (){
    late NonPersistedChatwootContactDao dao ;
    final testContact = ChatwootContact(
        id: 0,
        contactIdentifier: "contactIdentifier",
        pubsubToken: "pubsubToken",
        name: "name",
        email: "email"
    );

    setUp((){
      dao = NonPersistedChatwootContactDao();
    });

    test('Given contact is successfully deleted when deleteContact is called, then getContact should return null', () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      dao.deleteContact();

      //THEN
      expect(dao.getContact(), null);
    });

    test('Given contact is successfully save when saveContact is called, then getContact should return saved contact', () {

      //WHEN
      dao.saveContact(testContact);

      //THEN
      expect(dao.getContact(), testContact);
    });

    test('Given contact is successfully retrieved when getContact is called, then retrieved contact should not be null', () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      final retrievedContact = dao.getContact();

      //THEN
      expect(retrievedContact, testContact);
    });

    test('Given dao is successfully disposed when onDispose is called, then saved contact should be null', () {
      //GIVEN
      dao.saveContact(testContact);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedContact = dao.getContact();
      expect(retrievedContact, null);
    });
  });

}
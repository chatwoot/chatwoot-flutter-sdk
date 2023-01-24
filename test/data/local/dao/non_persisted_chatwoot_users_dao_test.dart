import 'package:chatwoot_sdk/data/local/dao/chatwoot_user_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Non Persisted Chatwoot Users Dao Test", () {
    late NonPersistedChatwootUserDao dao;
    final testUser = ChatwootUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});

    setUp(() {
      dao = NonPersistedChatwootUserDao();
    });

    test(
        'Given user is successfully deleted when deleteUser is called, then getUser should return null',
        () {
      //GIVEN
      dao.saveUser(testUser);

      //WHEN
      dao.deleteUser();

      //THEN
      expect(dao.getUser(), null);
    });

    test(
        'Given user is successfully saved when saveUser is called, then getUser should return saved user',
        () {
      //WHEN
      dao.saveUser(testUser);

      //THEN
      expect(dao.getUser(), testUser);
    });

    test(
        'Given user is successfully retrieved when getUser is called, then retrieved user should not be null',
        () {
      //GIVEN
      dao.saveUser(testUser);

      //WHEN
      final retrievedUser = dao.getUser();

      //THEN
      expect(retrievedUser, testUser);
    });

    test(
        'Given users are successfully cleared when clearAll is called, then retrieving a user should be null',
        () {
      //GIVEN
      dao.saveUser(testUser);

      //WHEN
      dao.clearAll();

      //THEN
      expect(dao.getUser(), null);
    });

    test(
        'Given dao is successfully disposed when onDispose is called, then saved user should be null',
        () {
      //GIVEN
      dao.saveUser(testUser);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedUser = dao.getUser();
      expect(retrievedUser, null);
    });
  });
}

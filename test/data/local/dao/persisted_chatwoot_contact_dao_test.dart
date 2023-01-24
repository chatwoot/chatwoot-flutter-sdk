import 'dart:io';

import 'package:chatwoot_sdk/data/local/dao/chatwoot_contact_dao.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Chatwoot Contact Dao Tests", () {
    late PersistedChatwootContactDao dao;
    late Box<String> mockClientInstanceKeyToContactBox;
    late Box<ChatwootContact> mockContactBox;
    final testClientInstanceKey = "testKey";

    late final ChatwootContact testContact;

    setUpAll(() {
      return Future(() async {
        testContact = ChatwootContact.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "contact"));
        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(ChatwootContactAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockContactBox =
            await Hive.openBox(ChatwootContactBoxNames.CONTACTS.toString());
        mockClientInstanceKeyToContactBox = await Hive.openBox(
            ChatwootContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());

        dao = PersistedChatwootContactDao(mockContactBox,
            mockClientInstanceKeyToContactBox, testClientInstanceKey);
      });
    });

    test(
        'Given contact is successfully deleted when deleteContact is called, then getContact should return null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      await dao.deleteContact();

      //THEN
      expect(dao.getContact(), null);
    });

    test(
        'Given contact is successfully save when saveContact is called, then getContact should return saved contact',
        () async {
      //WHEN
      await dao.saveContact(testContact);

      //THEN
      expect(dao.getContact(), testContact);
    });

    test(
        'Given contact is successfully retrieved when getContact is called, then retrieved contact should not be null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      final retrievedContact = dao.getContact();

      //THEN
      expect(retrievedContact, testContact);
    });

    test(
        'Given contacts are successfully cleared when clearAll is called, then retrieved contact should be null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getContact(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockContactBox.clear();
          await mockClientInstanceKeyToContactBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockContactBox.close();
        await mockClientInstanceKeyToContactBox.close();
      });
    });
  });
}

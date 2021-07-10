import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MockStringBox extends Fake implements Box<String>{

}

class MockContactBox extends Fake implements Box<ChatwootContact>{

}

class MockConversationBox extends Fake implements Box<ChatwootConversation>{

}

class MockMessagesBox extends Fake implements Box<ChatwootMessage>{

}

class MockUserBox extends Fake implements Box<ChatwootUser>{

}
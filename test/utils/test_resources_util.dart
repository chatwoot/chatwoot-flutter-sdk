import 'dart:convert';
import 'dart:io';

class TestResourceUtil {
  static Future<dynamic> readJsonResource({required String fileName}) async {
    final file = new File('test/resources/$fileName.json');
    final json = jsonDecode(await file.readAsString());
    return json;
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _checkinKey = 'checkin_records';
  static const _finishKey = 'finish_records';

  static Future<void> saveCheckin(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_checkinKey) ?? <String>[];
    list.add(jsonEncode(record));
    await prefs.setStringList(_checkinKey, list);
  }

  static Future<void> saveFinish(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_finishKey) ?? <String>[];
    list.add(jsonEncode(record));
    await prefs.setStringList(_finishKey, list);
  }

  static Future<List<Map<String, dynamic>>> getCheckinRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_checkinKey) ?? <String>[];
    return list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getFinishRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_finishKey) ?? <String>[];
    return list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }
}

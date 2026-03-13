import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _enabled = false;
  static String? _lastError;

  static bool get isEnabled => _enabled;
  static String? get lastError => _lastError;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on UnsupportedError {
        await Firebase.initializeApp();
      }
      _enabled = true;
      _lastError = null;
    } catch (error) {
      _enabled = false;
      _lastError = error.toString();
    }
  }

  static Future<bool> saveCheckin(Map<String, dynamic> record) async {
    return _saveRecord('checkins', record);
  }

  static Future<bool> saveFinish(Map<String, dynamic> record) async {
    return _saveRecord('finishes', record);
  }

  static Future<List<Map<String, dynamic>>> getCheckinRecords() async {
    return _getRecords('checkins');
  }

  static Future<List<Map<String, dynamic>>> getFinishRecords() async {
    return _getRecords('finishes');
  }

  static Future<bool> _saveRecord(
    String collectionName,
    Map<String, dynamic> record,
  ) async {
    await initialize();
    if (!_enabled) return false;

    try {
      final collection = FirebaseFirestore.instance.collection(collectionName);
      final docId = record['id']?.toString();
      if (docId == null || docId.isEmpty) {
        await collection.add(record);
      } else {
        await collection.doc(docId).set(record);
      }
      return true;
    } catch (error) {
      _lastError = error.toString();
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> _getRecords(
    String collectionName,
  ) async {
    await initialize();
    if (!_enabled) return <Map<String, dynamic>>[];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if ((data['id']?.toString().trim().isNotEmpty ?? false)) {
          return data;
        }
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (error) {
      _lastError = error.toString();
      return <Map<String, dynamic>>[];
    }
  }
}

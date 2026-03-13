import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadRecords();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadRecords() async {
    final localCheckins = await StorageService.getCheckinRecords();
    final localFinishes = await StorageService.getFinishRecords();
    final firebaseCheckins = await FirebaseService.getCheckinRecords();
    final firebaseFinishes = await FirebaseService.getFinishRecords();
    return {
      'localCheckins': localCheckins,
      'localFinishes': localFinishes,
      'firebaseCheckins': firebaseCheckins,
      'firebaseFinishes': firebaseFinishes,
    };
  }

  void _refresh() {
    setState(() {
      _recordsFuture = _loadRecords();
    });
  }

  Widget _buildRecordCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$key: ${value ?? '-'}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Records'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load records: ${snapshot.error}'));
          }

          final localCheckins =
              snapshot.data?['localCheckins'] ?? <Map<String, dynamic>>[];
          final localFinishes =
              snapshot.data?['localFinishes'] ?? <Map<String, dynamic>>[];
          final firebaseCheckins =
              snapshot.data?['firebaseCheckins'] ?? <Map<String, dynamic>>[];
          final firebaseFinishes =
              snapshot.data?['firebaseFinishes'] ?? <Map<String, dynamic>>[];

          if (localCheckins.isEmpty &&
              localFinishes.isEmpty &&
              firebaseCheckins.isEmpty &&
              firebaseFinishes.isEmpty) {
            return const Center(child: Text('No records saved yet.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    FirebaseService.isEnabled
                        ? 'Firebase status: Connected'
                        : 'Firebase status: Not configured (local save still works)',
                  ),
                ),
              ),
              Text(
                'Local Check-in Records (${localCheckins.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...localCheckins.map(
                (record) => _buildRecordCard(
                  'Check-in',
                  [
                    _kv('ID', record['id']),
                    _kv('Student ID', record['studentId']),
                    _kv('Check-in Timestamp', record['checkInTimestamp'] ?? record['timestamp']),
                    _kv('Created At', record['createdAt']),
                    _kv('QR', record['qrCodeValue']),
                    _kv('Latitude', record['latitude']),
                    _kv('Longitude', record['longitude']),
                    _kv('Previous Topic', record['previousClassTopic']),
                    _kv('Expected Topic', record['expectedTodayTopic']),
                    _kv('Mood', record['moodBeforeClass']),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Local Finish Class Records (${localFinishes.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...localFinishes.map(
                (record) => _buildRecordCard(
                  'Finish Class',
                  [
                    _kv('ID', record['id']),
                    _kv('Student ID', record['studentId']),
                    _kv('Finish Timestamp', record['finishTimestamp'] ?? record['timestamp']),
                    _kv('Created At', record['createdAt']),
                    _kv('QR', record['qrCodeValue']),
                    _kv('Latitude', record['latitude']),
                    _kv('Longitude', record['longitude']),
                    _kv('Learned Today', record['learnedToday']),
                    _kv('Feedback', record['feedback']),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Firebase Check-in Records (${firebaseCheckins.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...firebaseCheckins.map(
                (record) => _buildRecordCard(
                  'Cloud Check-in',
                  [
                    _kv('ID', record['id']),
                    _kv('Student ID', record['studentId']),
                    _kv('Check-in Timestamp', record['checkInTimestamp']),
                    _kv('Created At', record['createdAt']),
                    _kv('QR', record['qrCodeValue']),
                    _kv('Latitude', record['latitude']),
                    _kv('Longitude', record['longitude']),
                    _kv('Previous Topic', record['previousClassTopic']),
                    _kv('Expected Topic', record['expectedTodayTopic']),
                    _kv('Mood', record['moodBeforeClass']),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Firebase Finish Class Records (${firebaseFinishes.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...firebaseFinishes.map(
                (record) => _buildRecordCard(
                  'Cloud Finish Class',
                  [
                    _kv('ID', record['id']),
                    _kv('Student ID', record['studentId']),
                    _kv('Finish Timestamp', record['finishTimestamp']),
                    _kv('Created At', record['createdAt']),
                    _kv('QR', record['qrCodeValue']),
                    _kv('Latitude', record['latitude']),
                    _kv('Longitude', record['longitude']),
                    _kv('Learned Today', record['learnedToday']),
                    _kv('Feedback', record['feedback']),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

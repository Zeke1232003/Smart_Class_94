import 'package:flutter/material.dart';

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
    final checkins = await StorageService.getCheckinRecords();
    final finishes = await StorageService.getFinishRecords();
    return {
      'checkins': checkins,
      'finishes': finishes,
    };
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
      appBar: AppBar(title: const Text('Saved Records')),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load records: ${snapshot.error}'));
          }

          final checkins = snapshot.data?['checkins'] ?? <Map<String, dynamic>>[];
          final finishes = snapshot.data?['finishes'] ?? <Map<String, dynamic>>[];

          if (checkins.isEmpty && finishes.isEmpty) {
            return const Center(child: Text('No records saved yet.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                'Check-in Records (${checkins.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...checkins.map(
                (record) => _buildRecordCard(
                  'Check-in',
                  [
                    _kv('Timestamp', record['timestamp']),
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
                'Finish Class Records (${finishes.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...finishes.map(
                (record) => _buildRecordCard(
                  'Finish Class',
                  [
                    _kv('Timestamp', record['timestamp']),
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

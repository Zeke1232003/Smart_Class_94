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
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$key: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: '${value ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Map<String, dynamic>> records,
    required String cardTitle,
    required List<Widget> Function(Map<String, dynamic>) fieldsBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (${records.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'No records yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...records.map(
                (record) => _buildRecordCard(
                  cardTitle,
                  fieldsBuilder(record),
                ),
              ),
          ],
        ),
      ),
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

          final firebaseStatusText = FirebaseService.isEnabled
              ? 'Firebase status: Connected'
              : 'Firebase status: Not configured (local save still works)';
          final firebaseStatusColor = FirebaseService.isEnabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: firebaseStatusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      FirebaseService.isEnabled
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(firebaseStatusText)),
                  ],
                ),
              ),
              _buildSection(
                icon: Icons.save_alt_rounded,
                title: 'Local Check-in Records',
                records: localCheckins,
                cardTitle: 'Check-in',
                fieldsBuilder: (record) => [
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
              const SizedBox(height: 16),
              _buildSection(
                icon: Icons.task_alt_rounded,
                title: 'Local Finish Class Records',
                records: localFinishes,
                cardTitle: 'Finish Class',
                fieldsBuilder: (record) => [
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
              const SizedBox(height: 16),
              _buildSection(
                icon: Icons.cloud_done_rounded,
                title: 'Firebase Check-in Records',
                records: firebaseCheckins,
                cardTitle: 'Cloud Check-in',
                fieldsBuilder: (record) => [
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
              const SizedBox(height: 16),
              _buildSection(
                icon: Icons.cloud_sync_rounded,
                title: 'Firebase Finish Class Records',
                records: firebaseFinishes,
                cardTitle: 'Cloud Finish Class',
                fieldsBuilder: (record) => [
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
            ],
          );
        },
      ),
    );
  }
}

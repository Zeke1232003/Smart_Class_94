import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousClassController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  int? _mood;
  String? _qrValue;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _previousClassController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && mounted) {
      setState(() => _qrValue = code);
    }
  }

  Future<void> _captureLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Please enable location services.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is required.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_qrValue == null || _qrValue!.isEmpty) {
      _showMessage('Please scan QR code.');
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showMessage('Please capture GPS location.');
      return;
    }

    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    final record = {
      'id': now.microsecondsSinceEpoch.toString(),
      'studentId': null,
      'type': 'checkin',
      'checkInTimestamp': nowIso,
      'createdAt': nowIso,
      'qrCodeValue': _qrValue,
      'latitude': _latitude,
      'longitude': _longitude,
      'previousClassTopic': _previousClassController.text.trim(),
      'expectedTodayTopic': _expectedTopicController.text.trim(),
      'moodBeforeClass': _mood,
    };

    await StorageService.saveCheckin(record);
    final cloudSaved = await FirebaseService.saveCheckin(record);
    if (!mounted) return;
    _showMessage(
      cloudSaved
          ? 'Check-in saved (Local + Firebase).'
          : 'Check-in saved locally. Firebase not configured yet.',
    );
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _statusTile({
    required IconData icon,
    required String title,
    required bool ready,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ready
            ? colorScheme.primaryContainer.withValues(alpha: 0.55)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ready ? colorScheme.primary : colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $value',
              style: TextStyle(
                color: ready ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const moodOptions = [
      '😡 Very negative',
      '🙁 Negative',
      '😐 Neutral',
      '🙂 Positive',
      '😄 Very positive',
    ];

    final qrReady = _qrValue != null && _qrValue!.isNotEmpty;
    final gpsReady = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in (Before Class)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before Class Check-in',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complete all fields, scan the classroom QR, and capture your current location.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _previousClassController,
                        decoration: const InputDecoration(
                          labelText: 'Previous class topic',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _expectedTopicController,
                        decoration: const InputDecoration(
                          labelText: 'Expected topic today',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _mood,
                        decoration: const InputDecoration(labelText: 'Mood (1-5)'),
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1} - ${moodOptions[index]}'),
                          ),
                        ),
                        validator: (value) => value == null ? 'Required' : null,
                        onChanged: (value) => setState(() => _mood = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _scanQr,
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              label: const Text('Scan QR'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _captureLocation,
                              icon: const Icon(Icons.my_location_rounded),
                              label: const Text('Get GPS'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _statusTile(
                        icon: Icons.qr_code_2_rounded,
                        title: 'QR',
                        ready: qrReady,
                        value: _qrValue ?? 'Not scanned',
                      ),
                      const SizedBox(height: 8),
                      _statusTile(
                        icon: Icons.location_on_rounded,
                        title: 'GPS',
                        ready: gpsReady,
                        value: gpsReady
                            ? '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                            : 'Not captured',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Submit Check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

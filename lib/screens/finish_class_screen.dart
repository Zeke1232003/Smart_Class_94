import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedController = TextEditingController();
  final _feedbackController = TextEditingController();

  String? _qrValue;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _learnedController.dispose();
    _feedbackController.dispose();
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
      'type': 'finish',
      'finishTimestamp': nowIso,
      'createdAt': nowIso,
      'qrCodeValue': _qrValue,
      'latitude': _latitude,
      'longitude': _longitude,
      'learnedToday': _learnedController.text.trim(),
      'feedback': _feedbackController.text.trim(),
    };

    await StorageService.saveFinish(record);
    final cloudSaved = await FirebaseService.saveFinish(record);
    if (!mounted) return;
    _showMessage(
      cloudSaved
          ? 'Finish Class saved (Local + Firebase).'
          : 'Finish Class saved locally. Firebase not configured yet.',
    );
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class (After Class)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _learnedController,
                decoration: const InputDecoration(
                  labelText: 'What I learned today',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _scanQr,
                      child: const Text('Scan QR'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _captureLocation,
                      child: const Text('Get GPS'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('QR: ${_qrValue ?? '-'}'),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GPS: ${_latitude?.toStringAsFixed(6) ?? '-'}, ${_longitude?.toStringAsFixed(6) ?? '-'}',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Finish Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static const _apiKeyDefine = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appIdDefine = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderIdDefine = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectIdDefine = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static const _authDomainDefine = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucketDefine = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const _measurementIdDefine = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );
  static const _iosBundleIdDefine = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _buildWebOptions();
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return _buildNativeOptions();
      default:
        throw UnsupportedError('Unsupported platform for Firebase options.');
    }
  }

  static FirebaseOptions _buildWebOptions() {
    final apiKey = _resolveValue(_apiKeyDefine, 'FIREBASE_API_KEY');
    final appId = _resolveValue(_appIdDefine, 'FIREBASE_APP_ID');
    final messagingSenderId = _resolveValue(
      _messagingSenderIdDefine,
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    final projectId = _resolveValue(_projectIdDefine, 'FIREBASE_PROJECT_ID');
    final authDomain = _resolveValue(_authDomainDefine, 'FIREBASE_AUTH_DOMAIN');
    final storageBucket = _resolveValue(
      _storageBucketDefine,
      'FIREBASE_STORAGE_BUCKET',
    );
    final measurementId = _resolveValue(
      _measurementIdDefine,
      'FIREBASE_MEASUREMENT_ID',
    );

    _validateRequired(
      requiredValues: [apiKey, appId, messagingSenderId, projectId],
      sourceHint: '--dart-define or .env',
    );
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: _optional(authDomain),
      storageBucket: _optional(storageBucket),
      measurementId: _optional(measurementId),
    );
  }

  static FirebaseOptions _buildNativeOptions() {
    _validateRequired(
      requiredValues: [
        _apiKeyDefine,
        _appIdDefine,
        _messagingSenderIdDefine,
        _projectIdDefine,
      ],
      sourceHint: '--dart-define',
    );
    return FirebaseOptions(
      apiKey: _apiKeyDefine,
      appId: _appIdDefine,
      messagingSenderId: _messagingSenderIdDefine,
      projectId: _projectIdDefine,
      storageBucket: _optional(_storageBucketDefine),
      iosBundleId: _optional(_iosBundleIdDefine),
    );
  }

  static void _validateRequired({
    required List<String> requiredValues,
    required String sourceHint,
  }) {
    final isAnyMissing = requiredValues.any((value) => value.trim().isEmpty);
    if (isAnyMissing) {
      throw UnsupportedError(
        'Firebase options are missing. Provide values via $sourceHint for '
        'FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID, and FIREBASE_PROJECT_ID.',
      );
    }
  }

  static String _resolveValue(String fromDefine, String envKey) {
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) {
      return trimmedDefine;
    }
    final fromEnv = dotenv.env[envKey] ?? '';
    return fromEnv.trim();
  }

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

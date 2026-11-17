import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saludap/models/auth_model.dart';

class StoredSession {
  const StoredSession({required this.auth, required this.expiresAt});

  final AuthModel auth;
  final DateTime expiresAt;

  bool get needsRefresh =>
      expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 1)));
}

abstract interface class SessionStorage {
  Future<StoredSession?> read();
  Future<void> write(AuthModel auth);
  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'saludap_session';
  final FlutterSecureStorage _storage;

  @override
  Future<StoredSession?> read() async {
    final rawValue = await _storage.read(key: _sessionKey);
    if (rawValue == null) return null;

    try {
      final json = jsonDecode(rawValue) as Map<String, dynamic>;
      return StoredSession(
        auth: AuthModel.fromDataJson(
          Map<String, dynamic>.from(json['auth'] as Map),
        ),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthModel auth) async {
    final expiresAt = DateTime.now().add(
      Duration(seconds: auth.tokens.expiresIn),
    );
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'auth': auth.toJson(),
        'expiresAt': expiresAt.toIso8601String(),
      }),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}

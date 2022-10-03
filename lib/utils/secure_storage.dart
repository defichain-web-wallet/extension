import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureMemoryStorage {
  static final SecureMemoryStorage _singleton = SecureMemoryStorage._internal();

  factory SecureMemoryStorage() {
    return _singleton;
  }

  SecureMemoryStorage._internal();

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  static final SecureMemoryStorage instance = new SecureMemoryStorage();

  Future<void> updateField(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (err) {
      print(err);
    }
  }

  Future<String?> getField(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (err) {
      throw err;
    }
  }

  Future<void> deleteField(String key) async {
    try {
      return await _storage.delete(key: key);
    } catch (err) {
      throw err;
    }
  }
}
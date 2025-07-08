import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._privateConstructor();

  static final SecureStorageService _instance =
      SecureStorageService._privateConstructor();

  factory SecureStorageService() {
    return _instance;
  }

  static final _storage = const FlutterSecureStorage();
  static const _baseUrlKey = 'BASE_URL';

  static Future<String?> readBaseUrl() async {
    try {
      return await _storage.read(key: _baseUrlKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveBaseUrl(String baseUrl) async {
    try {
      if (baseUrl.isEmpty) {
        throw Exception('Base URL cannot be empty');
      }
      await _storage.write(key: _baseUrlKey, value: baseUrl);
    } catch (e) {
      throw Exception('Failed to save base URL: $e');
    }
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MySecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> writeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<void> saveLocale(String locale) async {
    await _storage.write(key: 'locale', value: locale);
  }

  Future<String?> readLocale() async {
    return await _storage.read(key: 'locale');
  }

  Future<void> deleteLocale() async {
    await _storage.delete(key: 'locale');
  }

  Future<void> writeUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  Future<String?> readUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: 'userId');
  }
}

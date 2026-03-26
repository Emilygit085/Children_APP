import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 持久化 JWT（移动端）；Web 上 secure storage 行为依平台而定。
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _key = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}

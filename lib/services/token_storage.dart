import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 持久化 JWT（移动端）；Web 上 secure storage 行为依平台而定。
///
/// 内存缓存：注册/登录后立刻会请求 `/auth/me`，Web 上 secure storage 写入可能
/// 尚未对下一次 `read()` 可见（尤其 HTTP 站点），导致首包请求不带 Authorization。
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _key = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 当前会话内与持久化同步的 token；优先于异步 read。
  String? _sessionToken;

  Future<void> save(String token) async {
    _sessionToken = token;
    await _storage.write(key: _key, value: token);
  }

  Future<String?> read() async {
    if (_sessionToken != null && _sessionToken!.isNotEmpty) {
      return _sessionToken;
    }
    final t = await _storage.read(key: _key);
    _sessionToken = t;
    return t;
  }

  Future<void> clear() async {
    _sessionToken = null;
    await _storage.delete(key: _key);
  }
}

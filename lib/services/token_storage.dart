import 'token_storage_platform.dart'
    if (dart.library.html) 'token_storage_platform_web.dart'
    if (dart.library.io) 'token_storage_platform_io.dart';

/// Persists JWTs across platforms.
///
/// Web uses plain localStorage on purpose. The current demo is deployed over
/// HTTP, and the secure-storage web plugin relies on Web Crypto APIs that can
/// fail in non-secure contexts, which breaks the register/login flow after the
/// token is issued.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _key = 'access_token';
  final TokenStoragePlatform _storage = createTokenStoragePlatform();

  String? _sessionToken;

  Future<void> save(String token) async {
    _sessionToken = token;
    try {
      await _storage.write(_key, token);
    } catch (_) {
      // Web 非安全上下文下可能无法持久化；保留会话内 token 供当前流程继续。
    }
  }

  Future<String?> read() async {
    if (_sessionToken != null && _sessionToken!.isNotEmpty) {
      return _sessionToken;
    }
    String? t;
    try {
      t = await _storage.read(_key);
    } catch (_) {
      // 持久化不可读时返回会话内 token（若有），避免流程中断。
      return _sessionToken;
    }
    _sessionToken = t;
    return t;
  }

  Future<void> clear() async {
    _sessionToken = null;
    try {
      await _storage.delete(_key);
    } catch (_) {
      // 持久化删除失败不应影响内存会话清理。
    }
  }
}

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
    await _storage.write(_key, token);
  }

  Future<String?> read() async {
    if (_sessionToken != null && _sessionToken!.isNotEmpty) {
      return _sessionToken;
    }
    final token = await _storage.read(_key);
    _sessionToken = token;
    return token;
  }

  Future<void> clear() async {
    _sessionToken = null;
    await _storage.delete(_key);
  }
}

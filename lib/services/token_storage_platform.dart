abstract class TokenStoragePlatform {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}

TokenStoragePlatform createTokenStoragePlatform() {
  throw UnsupportedError('No token storage platform implementation found.');
}

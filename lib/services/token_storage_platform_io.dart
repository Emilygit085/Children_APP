import 'package:flutter_secure_storage/flutter_secure_storage.dart';

export 'token_storage_platform.dart';

import 'token_storage_platform.dart';

class SecureTokenStoragePlatform implements TokenStoragePlatform {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}

TokenStoragePlatform createTokenStoragePlatform() {
  return SecureTokenStoragePlatform();
}

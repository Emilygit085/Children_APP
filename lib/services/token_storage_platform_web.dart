// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

export 'token_storage_platform.dart';

import 'token_storage_platform.dart';

class WebTokenStoragePlatform implements TokenStoragePlatform {
  @override
  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}

TokenStoragePlatform createTokenStoragePlatform() {
  return WebTokenStoragePlatform();
}

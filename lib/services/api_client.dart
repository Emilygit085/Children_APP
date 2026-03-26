import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'token_storage.dart';

/// 带 Authorization 的 Dio 单例（仅远程模式使用）。
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConfig.restBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = await TokenStorage.instance.read();
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          return handler.next(options);
        },
      ),
    );
    return d;
  }
}

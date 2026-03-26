/// 远程 API 配置。
///
/// 使用远端 FastAPI 时通过编译参数指定，例如：
/// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`
///
/// 未设置或为空字符串时，使用本地 SQLite（原有行为）。
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// 是否走远程 REST（非空 baseUrl 即启用）。
  static bool get useRemoteApi => baseUrl.trim().isNotEmpty;

  static String get restBase => '${baseUrl.replaceAll(RegExp(r'/$'), '')}/api/v1';

  /// WebSocket：`http` → `ws`，`https` → `wss`
  static String wsUrl(String token) {
    final root = baseUrl.replaceAll(RegExp(r'/$'), '');
    final wsRoot = root
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$wsRoot/ws?token=${Uri.encodeComponent(token)}';
  }
}

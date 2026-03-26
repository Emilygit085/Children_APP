import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_client.dart';

/// 远端聊天 REST（需 `API_BASE_URL` 与登录 token）。
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  Dio get _dio => ApiClient.instance.dio;

  bool get available => ApiConfig.useRemoteApi;

  Future<String?> findConversationIdForPeer(String peerUserId) async {
    final res = await _dio.get('/chat/conversations');
    final list = (res.data as List<dynamic>?) ?? [];
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      if (m['peer_user_id'] == peerUserId) {
        return m['id'] as String?;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId) async {
    final res = await _dio.get('/chat/conversations/$conversationId/messages');
    final list = (res.data as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> sendMessage(String peerUserId, String body) async {
    try {
      await _dio.post(
        '/chat/conversations/with/$peerUserId/messages',
        data: {'body': body},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? e.message ?? '发送失败');
    }
  }
}

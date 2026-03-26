import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../database/database_helper.dart';
import '../models/db_binding.dart';
import '../models/db_child_profile.dart';
import 'api_client.dart';

/// 绑定码与亲子绑定：本地或远端 FastAPI。
class BindingService {
  static final BindingService instance = BindingService._init();
  BindingService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;
  Dio get _dio => ApiClient.instance.dio;

  bool get _remote => ApiConfig.useRemoteApi;

  String _generateBindCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 1000000).toString().padLeft(6, '0');
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<String> generateBindCode(String parentUserId) async {
    if (_remote) {
      try {
        final res = await _dio.post<Map<String, dynamic>>('/bindings/parent/bind-code');
        return res.data!['code'] as String;
      } on DioException catch (e) {
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '生成失败');
      }
    }

    final profileMap = await _db.getParentProfileByUserId(parentUserId);
    if (profileMap == null) {
      throw Exception('家长资料不存在');
    }

    String bindCode = '';
    var codeExists = true;
    while (codeExists) {
      bindCode = _generateBindCode();
      final existing = await _db.getParentProfileByBindCode(bindCode);
      codeExists = existing != null;
    }

    await _db.updateParentProfile(parentUserId, {'bind_code': bindCode});
    return bindCode;
  }

  Future<String> getOrGenerateBindCode(String parentUserId) async {
    if (_remote) {
      return generateBindCode(parentUserId);
    }

    final profileMap = await _db.getParentProfileByUserId(parentUserId);
    if (profileMap == null) {
      throw Exception('家长资料不存在');
    }

    final bindCode = profileMap['bind_code'] as String?;
    if (bindCode != null && bindCode.isNotEmpty) {
      return bindCode;
    }

    return generateBindCode(parentUserId);
  }

  /// 儿童提交绑定码：远端创建 **pending**；本地仍为旧逻辑（直接 approved）。
  Future<bool> bindChildToParent(String childUserId, String bindCode) async {
    if (_remote) {
      try {
        await _dio.post<Map<String, dynamic>>(
          '/bindings/child/request',
          data: {'bind_code': bindCode.trim()},
        );
        return true;
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code == 400 || code == 429) return false;
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '绑定失败');
      }
    }

    final parentProfileMap = await _db.getParentProfileByBindCode(bindCode);
    if (parentProfileMap == null) {
      return false;
    }

    final parentUserId = parentProfileMap['user_id'] as String;

    final existingBinding = await _db.getBindingByChildId(childUserId);
    if (existingBinding != null) {
      return false;
    }

    final bindingId = _generateId();
    final binding = DbBinding(
      id: bindingId,
      parentUserId: parentUserId,
      childUserId: childUserId,
      bindCode: bindCode,
      status: 'approved',
    );

    await _db.insertBinding(binding.toMap());

    await _db.updateChildProfile(childUserId, {
      'parent_user_id': parentUserId,
    });

    return true;
  }

  Future<List<DbChildProfile>> getChildrenByParent(String parentUserId) async {
    if (_remote) {
      try {
        final res = await _dio.get('/users/parent/children');
        final list = (res.data as List<dynamic>?) ?? [];
        return list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return DbChildProfile(
            userId: m['user_id'] as String,
            childName: m['child_name'] as String,
            age: m['age'] as int,
            interests: List<String>.from(m['interests'] as List? ?? []),
            personality: List<String>.from(m['personality'] as List? ?? []),
            parentUserId: parentUserId,
          );
        }).toList();
      } on DioException catch (e) {
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '加载失败');
      }
    }

    final childrenMaps = await _db.getChildrenByParentId(parentUserId);
    return childrenMaps.map((map) => DbChildProfile.fromMap(map)).toList();
  }

  Future<String?> getParentByChild(String childUserId) async {
    if (_remote) {
      try {
        final me = await _dio.get<Map<String, dynamic>>('/auth/me');
        final cp = me.data?['child_profile'];
        if (cp == null) return null;
        return Map<String, dynamic>.from(cp as Map)['parent_user_id'] as String?;
      } on DioException {
        return null;
      }
    }
    final childProfileMap = await _db.getChildProfileByUserId(childUserId);
    if (childProfileMap == null) return null;
    return childProfileMap['parent_user_id'] as String?;
  }
}

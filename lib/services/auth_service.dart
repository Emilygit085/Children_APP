import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../database/database_helper.dart';
import '../models/db_child_profile.dart';
import '../models/db_parent_profile.dart';
import '../models/db_user.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// 认证与用户资料：本地 SQLite（`API_BASE_URL` 未设置）或远端 FastAPI。
class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  Dio get _dio => ApiClient.instance.dio;

  bool get _remote => ApiConfig.useRemoteApi;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<DbUser> register({
    required String username,
    required String password,
    required String role,
    String? parentName,
    String? childName,
    int? age,
  }) async {
    if (_remote) {
      try {
        if (role == 'parent') {
          final res = await _dio.post<Map<String, dynamic>>(
            '/auth/register/parent',
            data: {
              'username': username,
              'password': password,
              'display_name': parentName ?? '家长',
              'phone': null,
            },
          );
          final data = res.data!;
          await TokenStorage.instance.save(data['access_token'] as String);
          return DbUser.fromApiJson(Map<String, dynamic>.from(data['user'] as Map));
        }
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/register/child',
          data: {
            'username': username,
            'password': password,
            'child_name': childName ?? '我',
            'age': age ?? 8,
          },
        );
        final data = res.data!;
        await TokenStorage.instance.save(data['access_token'] as String);
        return DbUser.fromApiJson(Map<String, dynamic>.from(data['user'] as Map));
      } on DioException catch (e) {
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '注册失败');
      }
    }

    final existingUser = await _db.getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('用户名已存在');
    }

    final userId = _generateId();
    final passwordHash = _hashPassword(password);
    final createdAt = DateTime.now().toIso8601String();

    final user = DbUser(
      id: userId,
      username: username,
      passwordHash: passwordHash,
      role: role,
      createdAt: createdAt,
    );

    await _db.insertUser(user.toMap());

    if (role == 'parent') {
      if (parentName == null) {
        throw Exception('家长注册需要提供姓名');
      }
      final parentProfile = DbParentProfile(
        userId: userId,
        parentName: parentName,
      );
      await _db.insertParentProfile(parentProfile.toMap());
    } else if (role == 'child') {
      if (childName == null || age == null) {
        throw Exception('儿童注册需要提供姓名和年龄');
      }
      final childProfile = DbChildProfile(
        userId: userId,
        childName: childName,
        age: age,
        interests: [],
        personality: [],
      );
      await _db.insertChildProfile(childProfile.toMap());
    }

    return user;
  }

  Future<DbUser?> login(String username, String password) async {
    if (_remote) {
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: {'username': username, 'password': password},
        );
        final data = res.data!;
        await TokenStorage.instance.save(data['access_token'] as String);
        return DbUser.fromApiJson(Map<String, dynamic>.from(data['user'] as Map));
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) return null;
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '登录失败');
      }
    }

    final userMap = await _db.getUserByUsername(username);
    if (userMap == null) {
      return null;
    }

    final passwordHash = _hashPassword(password);
    if (userMap['password_hash'] != passwordHash) {
      return null;
    }

    return DbUser.fromMap(userMap);
  }

  /// 退出远端会话（清除 token）。
  Future<void> logoutRemote() async {
    await TokenStorage.instance.clear();
  }

  Future<DbUser?> getUserById(String userId) async {
    if (_remote) {
      final me = await _dio.get<Map<String, dynamic>>('/auth/me');
      final u = me.data?['user'];
      if (u == null) return null;
      final du = DbUser.fromApiJson(Map<String, dynamic>.from(u as Map));
      return du.id == userId ? du : null;
    }
    final userMap = await _db.getUserById(userId);
    if (userMap == null) return null;
    return DbUser.fromMap(userMap);
  }

  Future<DbParentProfile?> getParentProfile(String userId) async {
    if (_remote) {
      final me = await _dio.get<Map<String, dynamic>>('/auth/me');
      final pp = me.data?['parent_profile'];
      if (pp == null) return null;
      final m = Map<String, dynamic>.from(pp as Map);
      return DbParentProfile(
        userId: userId,
        parentName: m['display_name'] as String? ?? '家长',
        phone: m['phone'] as String?,
      );
    }
    final profileMap = await _db.getParentProfileByUserId(userId);
    if (profileMap == null) return null;
    return DbParentProfile.fromMap(profileMap);
  }

  Future<DbChildProfile?> getChildProfile(String userId) async {
    if (_remote) {
      final me = await _dio.get<Map<String, dynamic>>('/auth/me');
      final cp = me.data?['child_profile'];
      if (cp == null) return null;
      return DbChildProfile.fromApiJson(
        userId,
        Map<String, dynamic>.from(cp as Map),
      );
    }
    final profileMap = await _db.getChildProfileByUserId(userId);
    if (profileMap == null) return null;
    return DbChildProfile.fromMap(profileMap);
  }

  /// 更新儿童兴趣/性格（本地 SQLite 或远端 PATCH）。
  Future<void> updateChildProfile(
    String userId, {
    List<String>? interests,
    List<String>? personality,
  }) async {
    if (_remote) {
      try {
        await _dio.patch<Map<String, dynamic>>(
          '/users/me/child-profile',
          data: {
            if (interests != null) 'interests': interests,
            if (personality != null) 'personality': personality,
          },
        );
      } on DioException catch (e) {
        throw Exception(e.response?.data?['detail'] ?? e.message ?? '保存失败');
      }
      return;
    }

    final updates = <String, dynamic>{};
    if (interests != null) {
      updates['interests_json'] = jsonEncode(interests);
    }
    if (personality != null) {
      updates['personality_json'] = jsonEncode(personality);
    }
    if (updates.isEmpty) return;
    await _db.updateChildProfile(userId, updates);
  }
}

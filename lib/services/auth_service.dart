import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../models/db_user.dart';
import '../models/db_parent_profile.dart';
import '../models/db_child_profile.dart';

/// 认证服务
/// 负责用户注册、登录等认证相关操作
class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// 生成密码哈希
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 生成唯一ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 注册用户
  /// 
  /// 参数：
  /// - username: 用户名
  /// - password: 密码（明文）
  /// - role: 角色（'parent' 或 'child'）
  /// - parentName: 家长姓名（仅家长需要）
  /// - childName: 儿童姓名（仅儿童需要）
  /// - age: 年龄（仅儿童需要）
  /// 
  /// 返回：注册成功的用户信息
  Future<DbUser> register({
    required String username,
    required String password,
    required String role,
    String? parentName,
    String? childName,
    int? age,
  }) async {
    // 检查用户名是否已存在
    final existingUser = await _db.getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('用户名已存在');
    }

    // 创建用户
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

    // 插入用户
    await _db.insertUser(user.toMap());

    // 根据角色创建对应的资料
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

  /// 用户登录
  /// 
  /// 参数：
  /// - username: 用户名
  /// - password: 密码（明文）
  /// 
  /// 返回：登录成功的用户信息，如果失败返回 null
  Future<DbUser?> login(String username, String password) async {
    // 查询用户
    final userMap = await _db.getUserByUsername(username);
    if (userMap == null) {
      return null;
    }

    // 验证密码
    final passwordHash = _hashPassword(password);
    if (userMap['password_hash'] != passwordHash) {
      return null;
    }

    return DbUser.fromMap(userMap);
  }

  /// 根据用户ID获取用户信息
  Future<DbUser?> getUserById(String userId) async {
    final userMap = await _db.getUserById(userId);
    if (userMap == null) return null;
    return DbUser.fromMap(userMap);
  }

  /// 获取家长资料
  Future<DbParentProfile?> getParentProfile(String userId) async {
    final profileMap = await _db.getParentProfileByUserId(userId);
    if (profileMap == null) return null;
    return DbParentProfile.fromMap(profileMap);
  }

  /// 获取儿童资料
  Future<DbChildProfile?> getChildProfile(String userId) async {
    final profileMap = await _db.getChildProfileByUserId(userId);
    if (profileMap == null) return null;
    return DbChildProfile.fromMap(profileMap);
  }
}

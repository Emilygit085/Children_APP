import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_storage_helper.dart';

/// 数据库辅助类
/// 负责数据库的创建、升级和基本操作
/// Web 平台使用内存存储，移动平台使用 SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final WebStorageHelper _webStorage = WebStorageHelper.instance;

  DatabaseHelper._init();

  /// 获取数据库实例（单例模式，仅移动平台）
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Web 平台使用内存存储，不需要 database getter');
    }
    if (_database != null) return _database!;
    _database = await _initDB('social_app.db');
    return _database!;
  }

  /// 初始化数据库（仅移动平台）
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// 创建数据库表
  Future<void> _createDB(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 家长资料表
    await db.execute('''
      CREATE TABLE parent_profiles (
        user_id TEXT PRIMARY KEY,
        parent_name TEXT NOT NULL,
        phone TEXT,
        bind_code TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 儿童资料表
    await db.execute('''
      CREATE TABLE child_profiles (
        user_id TEXT PRIMARY KEY,
        child_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        interests_json TEXT,
        personality_json TEXT,
        parent_user_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (parent_user_id) REFERENCES users (id)
      )
    ''');

    // 绑定关系表
    await db.execute('''
      CREATE TABLE bindings (
        id TEXT PRIMARY KEY,
        parent_user_id TEXT NOT NULL,
        child_user_id TEXT NOT NULL,
        bind_code TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (parent_user_id) REFERENCES users (id),
        FOREIGN KEY (child_user_id) REFERENCES users (id)
      )
    ''');
  }

  /// 关闭数据库
  Future<void> close() async {
    if (kIsWeb) {
      // Web 平台使用内存存储，无需关闭
      return;
    }
    final db = await database;
    await db.close();
  }

  // ========== 用户表操作 ==========

  /// 插入用户
  Future<void> insertUser(Map<String, dynamic> user) async {
    if (kIsWeb) {
      return await _webStorage.insertUser(user);
    }
    final db = await database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据用户名查询用户
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    if (kIsWeb) {
      return await _webStorage.getUserByUsername(username);
    }
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  /// 根据ID查询用户
  Future<Map<String, dynamic>?> getUserById(String id) async {
    if (kIsWeb) {
      return await _webStorage.getUserById(id);
    }
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // ========== 家长资料表操作 ==========

  /// 插入家长资料
  Future<void> insertParentProfile(Map<String, dynamic> profile) async {
    if (kIsWeb) {
      return await _webStorage.insertParentProfile(profile);
    }
    final db = await database;
    await db.insert('parent_profiles', profile, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 更新家长资料
  Future<void> updateParentProfile(String userId, Map<String, dynamic> updates) async {
    if (kIsWeb) {
      return await _webStorage.updateParentProfile(userId, updates);
    }
    final db = await database;
    await db.update('parent_profiles', updates, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// 根据用户ID查询家长资料
  Future<Map<String, dynamic>?> getParentProfileByUserId(String userId) async {
    if (kIsWeb) {
      return await _webStorage.getParentProfileByUserId(userId);
    }
    final db = await database;
    final result = await db.query(
      'parent_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  /// 根据绑定码查询家长资料
  Future<Map<String, dynamic>?> getParentProfileByBindCode(String bindCode) async {
    if (kIsWeb) {
      return await _webStorage.getParentProfileByBindCode(bindCode);
    }
    final db = await database;
    final result = await db.query(
      'parent_profiles',
      where: 'bind_code = ?',
      whereArgs: [bindCode],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // ========== 儿童资料表操作 ==========

  /// 插入儿童资料
  Future<void> insertChildProfile(Map<String, dynamic> profile) async {
    if (kIsWeb) {
      return await _webStorage.insertChildProfile(profile);
    }
    final db = await database;
    await db.insert('child_profiles', profile, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 更新儿童资料
  Future<void> updateChildProfile(String userId, Map<String, dynamic> updates) async {
    if (kIsWeb) {
      return await _webStorage.updateChildProfile(userId, updates);
    }
    final db = await database;
    await db.update('child_profiles', updates, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// 根据用户ID查询儿童资料
  Future<Map<String, dynamic>?> getChildProfileByUserId(String userId) async {
    if (kIsWeb) {
      return await _webStorage.getChildProfileByUserId(userId);
    }
    final db = await database;
    final result = await db.query(
      'child_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  /// 根据家长ID查询所有绑定的儿童
  Future<List<Map<String, dynamic>>> getChildrenByParentId(String parentUserId) async {
    if (kIsWeb) {
      return await _webStorage.getChildrenByParentId(parentUserId);
    }
    final db = await database;
    return await db.query(
      'child_profiles',
      where: 'parent_user_id = ?',
      whereArgs: [parentUserId],
    );
  }

  // ========== 绑定关系表操作 ==========

  /// 插入绑定关系
  Future<void> insertBinding(Map<String, dynamic> binding) async {
    if (kIsWeb) {
      return await _webStorage.insertBinding(binding);
    }
    final db = await database;
    await db.insert('bindings', binding, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 更新绑定状态
  Future<void> updateBindingStatus(String id, String status) async {
    if (kIsWeb) {
      return await _webStorage.updateBindingStatus(id, status);
    }
    final db = await database;
    await db.update('bindings', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  /// 根据绑定码查询绑定关系
  Future<Map<String, dynamic>?> getBindingByCode(String bindCode) async {
    if (kIsWeb) {
      return await _webStorage.getBindingByCode(bindCode);
    }
    final db = await database;
    final result = await db.query(
      'bindings',
      where: 'bind_code = ?',
      whereArgs: [bindCode],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  /// 根据家长ID查询所有绑定关系
  Future<List<Map<String, dynamic>>> getBindingsByParentId(String parentUserId) async {
    if (kIsWeb) {
      return await _webStorage.getBindingsByParentId(parentUserId);
    }
    final db = await database;
    return await db.query(
      'bindings',
      where: 'parent_user_id = ?',
      whereArgs: [parentUserId],
    );
  }

  /// 根据儿童ID查询绑定关系
  Future<Map<String, dynamic>?> getBindingByChildId(String childUserId) async {
    if (kIsWeb) {
      return await _webStorage.getBindingByChildId(childUserId);
    }
    final db = await database;
    final result = await db.query(
      'bindings',
      where: 'child_user_id = ?',
      whereArgs: [childUserId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }
}

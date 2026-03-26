/// 数据库用户模型（用于存储到 SQLite）
class DbUser {
  final String id;
  final String username;
  final String passwordHash;
  final String role; // 'parent' 或 'child'
  final String createdAt;

  DbUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  /// 来自远端 `/auth/login` 等返回的 `user` 对象。
  factory DbUser.fromApiJson(Map<String, dynamic> json) {
    return DbUser(
      id: json['id'] as String,
      username: json['username'] as String,
      passwordHash: '',
      role: json['role'] as String,
      createdAt: '',
    );
  }

  /// 从 Map 创建（从数据库读取）
  factory DbUser.fromMap(Map<String, dynamic> map) {
    return DbUser(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  /// 转换为 Map（用于数据库写入）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'created_at': createdAt,
    };
  }
}

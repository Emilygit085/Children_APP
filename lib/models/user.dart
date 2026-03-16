/// 用户角色枚举
enum UserRole {
  parent, // 家长
  child,  // 儿童
}

class User {
  final String id;
  final String name;
  final String avatar;
  final int age;
  final List<String> interests;
  final List<String> personality;
  final String location;
  final UserRole role; // 用户角色

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.age,
    required this.interests,
    required this.personality,
    required this.location,
    required this.role,
  });

  /// 是否为家长
  bool get isParent => role == UserRole.parent;

  /// 是否为儿童
  bool get isChild => role == UserRole.child;
}

import 'user.dart';

/// 当前用户数据管理（使用静态变量模拟，实际项目中应使用 SharedPreferences 或数据库）
class CurrentUser {
  static User? _user;
  static bool _hasSelectedInterests = false;

  /// 获取当前用户
  static User? get user => _user;

  /// 是否已选择兴趣
  static bool get hasSelectedInterests => _hasSelectedInterests;

  /// 是否为家长
  static bool get isParent => _user?.isParent ?? false;

  /// 是否为儿童
  static bool get isChild => _user?.isChild ?? false;

  /// 设置当前用户
  static void setUser(User user) {
    _user = user;
  }

  /// 设置用户兴趣
  static void setInterests(List<String> interests) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        avatar: _user!.avatar,
        age: _user!.age,
        interests: interests,
        personality: _user!.personality,
        location: _user!.location,
        role: _user!.role,
      );
      _hasSelectedInterests = true;
    }
  }

  /// 初始化默认儿童用户（用于测试）
  static void initDefaultChildUser() {
    _user = User(
      id: '0',
      name: '我',
      avatar: 'assets/images/avatar1.png', //asset assets\images\Avatar1.png
      age: 8,
      interests: [], // 初始为空，需要选择
      personality: [], // 初始为空，需要选择
      location: '附近',
      role: UserRole.child,
    );
    _hasSelectedInterests = false;
  }

  /// 初始化默认家长用户（用于测试）
  static void initDefaultParentUser() {
    _user = User(
      id: 'parent_0',
      name: '家长',
      avatar: 'assets/images/avatar1.png', //asset
      age: 35,
      interests: [],
      personality: [],
      location: '附近',
      role: UserRole.parent,
    );
    _hasSelectedInterests = false;
  }

  /// 初始化默认用户（用于测试，保持向后兼容）
  static void initDefaultUser() {
    initDefaultChildUser();
  }

  /// 重置（用于登出）
  static void reset() {
    _user = null;
    _hasSelectedInterests = false;
  }
}

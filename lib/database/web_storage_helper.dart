/// Web 平台内存存储辅助类
/// 用于在 Web 平台模拟数据库操作（仅用于 Demo）
class WebStorageHelper {
  static final WebStorageHelper instance = WebStorageHelper._init();
  
  // 内存存储
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, Map<String, dynamic>> _parentProfiles = {};
  final Map<String, Map<String, dynamic>> _childProfiles = {};
  final Map<String, Map<String, dynamic>> _bindings = {};
  
  WebStorageHelper._init();

  // ========== 用户表操作 ==========

  Future<void> insertUser(Map<String, dynamic> user) async {
    _users[user['id'] as String] = Map<String, dynamic>.from(user);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    for (var user in _users.values) {
      if (user['username'] == username) {
        return Map<String, dynamic>.from(user);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return _users[id] != null ? Map<String, dynamic>.from(_users[id]!) : null;
  }

  // ========== 家长资料表操作 ==========

  Future<void> insertParentProfile(Map<String, dynamic> profile) async {
    _parentProfiles[profile['user_id'] as String] = Map<String, dynamic>.from(profile);
  }

  Future<void> updateParentProfile(String userId, Map<String, dynamic> updates) async {
    if (_parentProfiles.containsKey(userId)) {
      _parentProfiles[userId]!.addAll(updates);
    }
  }

  Future<Map<String, dynamic>?> getParentProfileByUserId(String userId) async {
    return _parentProfiles[userId] != null 
        ? Map<String, dynamic>.from(_parentProfiles[userId]!) 
        : null;
  }

  Future<Map<String, dynamic>?> getParentProfileByBindCode(String bindCode) async {
    for (var profile in _parentProfiles.values) {
      if (profile['bind_code'] == bindCode) {
        return Map<String, dynamic>.from(profile);
      }
    }
    return null;
  }

  // ========== 儿童资料表操作 ==========

  Future<void> insertChildProfile(Map<String, dynamic> profile) async {
    _childProfiles[profile['user_id'] as String] = Map<String, dynamic>.from(profile);
  }

  Future<void> updateChildProfile(String userId, Map<String, dynamic> updates) async {
    if (_childProfiles.containsKey(userId)) {
      _childProfiles[userId]!.addAll(updates);
    }
  }

  Future<Map<String, dynamic>?> getChildProfileByUserId(String userId) async {
    return _childProfiles[userId] != null 
        ? Map<String, dynamic>.from(_childProfiles[userId]!) 
        : null;
  }

  Future<List<Map<String, dynamic>>> getChildrenByParentId(String parentUserId) async {
    final List<Map<String, dynamic>> result = [];
    for (var profile in _childProfiles.values) {
      if (profile['parent_user_id'] == parentUserId) {
        result.add(Map<String, dynamic>.from(profile));
      }
    }
    return result;
  }

  // ========== 绑定关系表操作 ==========

  Future<void> insertBinding(Map<String, dynamic> binding) async {
    _bindings[binding['id'] as String] = Map<String, dynamic>.from(binding);
  }

  Future<void> updateBindingStatus(String id, String status) async {
    if (_bindings.containsKey(id)) {
      _bindings[id]!['status'] = status;
    }
  }

  Future<Map<String, dynamic>?> getBindingByCode(String bindCode) async {
    for (var binding in _bindings.values) {
      if (binding['bind_code'] == bindCode) {
        return Map<String, dynamic>.from(binding);
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getBindingsByParentId(String parentUserId) async {
    final List<Map<String, dynamic>> result = [];
    for (var binding in _bindings.values) {
      if (binding['parent_user_id'] == parentUserId) {
        result.add(Map<String, dynamic>.from(binding));
      }
    }
    return result;
  }

  Future<Map<String, dynamic>?> getBindingByChildId(String childUserId) async {
    for (var binding in _bindings.values) {
      if (binding['child_user_id'] == childUserId) {
        return Map<String, dynamic>.from(binding);
      }
    }
    return null;
  }
}

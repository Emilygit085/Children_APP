/// 绑定关系模型
class Binding {
  final String id;
  final String parentId; // 家长ID
  final String childId; // 儿童ID
  final DateTime bindTime; // 绑定时间

  Binding({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.bindTime,
  });
}

/// 绑定码模型
class BindingCode {
  final String code; // 6位绑定码
  final String parentId; // 家长ID
  final DateTime createTime; // 创建时间
  final DateTime? expireTime; // 过期时间（可选）
  final bool isUsed; // 是否已使用

  BindingCode({
    required this.code,
    required this.parentId,
    required this.createTime,
    this.expireTime,
    this.isUsed = false,
  });

  /// 是否过期
  bool get isExpired {
    if (expireTime == null) return false;
    return DateTime.now().isAfter(expireTime!);
  }

  /// 是否有效（未使用且未过期）
  bool get isValid => !isUsed && !isExpired;
}

/// 绑定码管理（使用静态变量模拟，实际项目中应使用数据库）
class BindingCodeManager {
  // 存储所有绑定码
  static final Map<String, BindingCode> _bindingCodes = {};
  
  // 存储所有绑定关系
  static final List<Binding> _bindings = [];

  /// 生成6位绑定码
  static String generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = (random % 1000000).toString().padLeft(6, '0');
    return code;
  }

  /// 创建绑定码
  static BindingCode createBindingCode(String parentId) {
    final code = generateCode();
    final bindingCode = BindingCode(
      code: code,
      parentId: parentId,
      createTime: DateTime.now(),
      expireTime: DateTime.now().add(const Duration(hours: 24)), // 24小时过期
    );
    _bindingCodes[code] = bindingCode;
    return bindingCode;
  }

  /// 验证绑定码
  static BindingCode? validateCode(String code) {
    final bindingCode = _bindingCodes[code];
    if (bindingCode == null) return null;
    if (!bindingCode.isValid) return null;
    return bindingCode;
  }

  /// 使用绑定码进行绑定
  static Binding? bind(String code, String childId) {
    final bindingCode = validateCode(code);
    if (bindingCode == null) return null;

    // 检查是否已经绑定过
    if (_bindings.any((b) => b.childId == childId && b.parentId == bindingCode.parentId)) {
      return null; // 已经绑定过
    }

    // 创建绑定关系
    final binding = Binding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: bindingCode.parentId,
      childId: childId,
      bindTime: DateTime.now(),
    );

    _bindings.add(binding);
    
    // 标记绑定码为已使用
    _bindingCodes[code] = BindingCode(
      code: bindingCode.code,
      parentId: bindingCode.parentId,
      createTime: bindingCode.createTime,
      expireTime: bindingCode.expireTime,
      isUsed: true,
    );

    return binding;
  }

  /// 获取家长绑定的所有儿童
  static List<String> getBoundChildren(String parentId) {
    return _bindings
        .where((b) => b.parentId == parentId)
        .map((b) => b.childId)
        .toList();
  }

  /// 获取儿童绑定的家长
  static String? getBoundParent(String childId) {
    final binding = _bindings.firstWhere(
      (b) => b.childId == childId,
      orElse: () => Binding(
        id: '',
        parentId: '',
        childId: '',
        bindTime: DateTime.now(),
      ),
    );
    return binding.parentId.isEmpty ? null : binding.parentId;
  }

  /// 解除绑定
  static bool unbind(String parentId, String childId) {
    final index = _bindings.indexWhere(
      (b) => b.parentId == parentId && b.childId == childId,
    );
    if (index != -1) {
      _bindings.removeAt(index);
      return true;
    }
    return false;
  }

  /// 获取绑定码信息
  static BindingCode? getBindingCode(String code) {
    return _bindingCodes[code];
  }

  /// 清理过期的绑定码（可选，用于定期清理）
  static void cleanExpiredCodes() {
    _bindingCodes.removeWhere((code, bindingCode) => bindingCode.isExpired);
  }
}

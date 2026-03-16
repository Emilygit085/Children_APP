import 'dart:convert';

/// 儿童资料模型（用于存储到 SQLite）
class DbChildProfile {
  final String userId;
  final String childName;
  final int age;
  final List<String> interests;
  final List<String> personality;
  final String? parentUserId; // 绑定的家长用户ID

  DbChildProfile({
    required this.userId,
    required this.childName,
    required this.age,
    required this.interests,
    required this.personality,
    this.parentUserId,
  });

  /// 从 Map 创建（从数据库读取）
  factory DbChildProfile.fromMap(Map<String, dynamic> map) {
    List<String> interestsList = [];
    if (map['interests_json'] != null) {
      try {
        final decoded = jsonDecode(map['interests_json'] as String);
        if (decoded is List) {
          interestsList = decoded.cast<String>();
        }
      } catch (e) {
        // 解析失败，使用空列表
      }
    }

    List<String> personalityList = [];
    if (map['personality_json'] != null) {
      try {
        final decoded = jsonDecode(map['personality_json'] as String);
        if (decoded is List) {
          personalityList = decoded.cast<String>();
        }
      } catch (e) {
        // 解析失败，使用空列表
      }
    }

    return DbChildProfile(
      userId: map['user_id'] as String,
      childName: map['child_name'] as String,
      age: map['age'] as int,
      interests: interestsList,
      personality: personalityList,
      parentUserId: map['parent_user_id'] as String?, 
    );
  }

  /// 转换为 Map（用于数据库写入）
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'child_name': childName,
      'age': age,
      'interests_json': jsonEncode(interests),
      'personality_json': jsonEncode(personality),
      'parent_user_id': parentUserId,
    };
  }
}

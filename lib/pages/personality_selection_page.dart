import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/current_user.dart';
import '../database/database_helper.dart';

class PersonalitySelectionPage extends StatefulWidget {
  const PersonalitySelectionPage({Key? key}) : super(key: key);

  @override
  State<PersonalitySelectionPage> createState() => _PersonalitySelectionPageState();
}

class _PersonalitySelectionPageState extends State<PersonalitySelectionPage> {
  // 性格选项列表
  final List<String> _personalityOptions = [
    '外向开朗',
    '安静内向',
    '乐观阳光',
    '善于观察',
    '精力充沛',
    '热爱思辨',
    '喜欢想象',
    '乐于社交',
    '亲近自然',
    '细心爱心',
    '善良可亲',
    '勇于尝试',
    '喜爱研究',
    '独立自主',
    '幽默风趣',
  ];

  // 用户已选择的性格
  final Set<String> _selectedPersonalities = {};

  Future<void> _handleComplete() async {
    if (_selectedPersonalities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少选择一个性格特征'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUser = CurrentUser.user;
    if (currentUser == null || !currentUser.isChild) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('用户信息错误'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 保存性格到数据库
      final personalitiesList = _selectedPersonalities.toList();
      await DatabaseHelper.instance.updateChildProfile(
        currentUser.id,
        {'personality_json': personalitiesList.toString()},
      );

      // 更新当前用户
      if (CurrentUser.user != null) {
        final updatedUser = User(
          id: CurrentUser.user!.id,
          name: CurrentUser.user!.name,
          avatar: CurrentUser.user!.avatar,
          age: CurrentUser.user!.age,
          interests: CurrentUser.user!.interests,
          personality: personalitiesList,
          location: CurrentUser.user!.location,
          role: CurrentUser.user!.role,
        );
        CurrentUser.setUser(updatedUser);
      }

      // 跳转到兴趣大类选择页面
      Navigator.pushNamed(context, '/interest-category-selection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败：${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text(
          '选择性格特征',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.purple[400],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 提示文字
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[800],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '你认为自己是什么样的？选择符合你性格的特征，我们会为你推荐志同道合的小伙伴！',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 性格选择标题
                    Text(
                      '🎯 选择你的性格特征',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 性格选项网格
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _personalityOptions.map((personality) {
                            final bool isSelected = _selectedPersonalities.contains(personality);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPersonalities.remove(personality);
                                  } else {
                                    _selectedPersonalities.add(personality);
                                  }
                                });
                              },
                              child: _PersonalityCard(
                                label: personality,
                                selected: isSelected,
                                width: (constraints.maxWidth - 12) / 2, // 两列布局
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // 已选择提示
                    if (_selectedPersonalities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '已选择 ${_selectedPersonalities.length} 个性格特征',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 完成按钮
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalityCard extends StatelessWidget {
  final String label;
  final bool selected;
  final double width;

  const _PersonalityCard({
    Key? key,
    required this.label,
    required this.selected,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = selected
        ? [Colors.purple[400]!, Colors.purple[600]!]
        : [Colors.orange[200]!, Colors.pink[200]!];

    return Container(
      width: width.clamp(140, 260),
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 模拟图片的浅色叠层
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            right: 12,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/current_user.dart';
import '../database/database_helper.dart';

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({Key? key}) : super(key: key);

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  final List<InterestCategory> _categories = [
    InterestCategory(
      id: 'sport',
      name: '运动户外',
      emoji: '⚽',
      subcategories: [
        '⚽足球', '🏀篮球', '🏓乒乓球', '🏸羽毛球', '🎾网球', '🚴骑行', '🏃跑步', '🏊游泳','💃🏻跳舞',
        '⛰️爬山', '🤸跳绳', '🛼轮滑', '🛹滑板', '🚶徒步', '🏕️露营', '🤸体操', '🥋跆拳道', '⚽其他运动'
      ],
    ),
    InterestCategory(
      id: 'craft',
      name: '手工制作',
      emoji: '✂️',
      subcategories: [
        '🧩乐高', '✈️航模', '📃折纸', '🏺黏土泥塑', '🧩拼图', '🧶编织缝纫', '🔨金工木工', '🐑羊毛毡',
        '📄纸雕', '💧流沙滴胶', '🏺陶艺', '🎨拼贴画', '♻️废旧改造', '📿串珠', '✂️其他制作'
      ],
    ),
    InterestCategory(
      id: 'reading',
      name: '阅读写作',
      emoji: '📚',
      subcategories: [
        '📖读诗歌', '📙读小说', '📗读散文', '📰读报刊', '🔬读科普', '📜读历史', '📚读社科', '🌍读外语',
        '✍️写小说散文', '📝写诗', '📓写日记', '📔做读书笔记', '📚其他读物'
      ],
    ),
    InterestCategory(
      id: 'music',
      name: '音乐世界',
      emoji: '🎵',
      subcategories: [
        '🎤独唱', '🎙️合唱', '🎶民乐演奏', '🎹西乐演奏', '📝谱曲', '🎧流行乐', '🎼古典乐', '🎸摇滚乐',
        '🪇民谣', '🎤说唱', '🎵R&B', '🎷爵士', '🎬动漫影视音乐', '🎵纯音乐', '🎵其他音乐'
      ],
    ),
    InterestCategory(
      id: 'art',
      name: '美术设计',
      emoji: '🎨',
      subcategories: [
        '🎨传统绘画', '✍🏻漫画插画', '🖌️书法', '📷摄影', '📔手账', '🏗️建模', '✏️涂鸦', '🎨逛美术馆',
        '🖼️收藏画集', '🎨其他美术设计'
      ],
    ),
    InterestCategory(
      id: 'tech',
      name: '科技科创',
      emoji: '🔬',
      subcategories: [
        '💻编程', '🤖机器人', '🔌pcb电路板', '🖨️3D打印', '🔬科学实验', '🧮梳理推算', '🔭天文观测', '🔬其余科创'
      ],
    ),
    InterestCategory(
      id: 'movie',
      name: '电影戏剧',
      emoji: '🎬',
      subcategories: [
        '🎬看电影', '🎵音乐剧', '🎭话剧', '🎤歌剧', '💃舞剧', '🎭戏剧表演', '📹电影拍摄', '🎤配音'
      ],
    ),
    InterestCategory(
      id: 'acgn',
      name: 'ACGN',
      emoji: '🎮',
      subcategories: [
        '📺番剧', '📚漫画', '💻PC游戏', '🎮主机游戏', '📱手游', '📖轻小说', '🎮视觉小说', '🎨同人创作', '🎮其他acgn相关'
      ],
    ),
    InterestCategory(
      id: 'board',
      name: '棋牌桌游',
      emoji: '♟️',
      subcategories: [
        '♟️象棋', '⚪围棋', '⚫五子棋', '✈️飞行棋', '💰大富翁', '🎴uno', '🐺狼人杀', '📖剧本杀', '⚔️三国杀', '♟️其他棋牌桌游'
      ],
    ),
    InterestCategory(
      id: 'food',
      name: '美食烹饪',
      emoji: '🍳',
      subcategories: [
        '🥢中餐', '🍝西餐', '🍣日料', '🍜韩餐', '🍰甜点', '🥛奶制品', '🍪小食零食', '📖研究菜谱', '🍳其他食物制作'
      ],
    ),
    InterestCategory(
      id: 'animal',
      name: '动物植物',
      emoji: '🐶',
      subcategories: [
        '🐶狗狗', '🐱猫咪', '🐰兔', '🐭鼠', '🐦鸟', '🐟鱼', '🦎爬行动物', '🦋昆虫', '🌵多肉', '🌳树木', '🌸花草'
      ],
    ),
    InterestCategory(
      id: 'life',
      name: '休闲生活',
      emoji: '🏖️',
      subcategories: [
        '✈️旅行', '🏙️城市探索', '🚶散步', '🧹整理', '💬聊天', '🛒逛超市', '📮集邮', '🏖️其他活动'
      ],
    ),
  ];

  List<String> _selectedCategoryIds = [];
  String _currentCategoryId = '';
  final Set<String> _selectedInterests = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _selectedCategoryIds = args;
      if (_selectedCategoryIds.isNotEmpty) {
        // 按固定顺序排序的分类列表中找到第一个被选中的分类
        final firstSelectedCategory = _categories.firstWhere(
          (cat) => _selectedCategoryIds.contains(cat.id),
          orElse: () => _categories.first,
        );
        _currentCategoryId = firstSelectedCategory.id;
      }
    }
  }

  List<InterestCategory> get _filteredCategories {
    return _categories.where((cat) => _selectedCategoryIds.contains(cat.id)).toList();
  }

  Future<void> _handleComplete() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少选择一个兴趣爱好'),
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
      final interestsList = _selectedInterests.toList();
      await DatabaseHelper.instance.updateChildProfile(
        currentUser.id,
        {'interests_json': jsonEncode(interestsList)},
      );

      CurrentUser.setInterests(interestsList);
      Navigator.pushReplacementNamed(context, '/home');
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
          '选择具体爱好',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.purple[400],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                              '选择你喜欢的具体兴趣爱好！想重新选择大类？点击左上角的返回按钮。',
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
                    Text(
                      '🎯 选择具体爱好',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_filteredCategories.length > 1)
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filteredCategories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = _filteredCategories[index];
                            final bool selected = cat.id == _currentCategoryId;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentCategoryId = cat.id;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.purple[400]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.purple[600]!
                                        : Colors.purple[200]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${cat.emoji} ${cat.name}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: selected
                                          ? Colors.white
                                          : Colors.purple[700],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_filteredCategories.length > 1)
                      const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final currentCategory = _filteredCategories.firstWhere(
                          (cat) => cat.id == _currentCategoryId,
                          orElse: () => _filteredCategories.first,
                        );
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: currentCategory.subcategories.map((subcategory) {
                            final bool isSelected = _selectedInterests.contains(subcategory);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedInterests.remove(subcategory);
                                  } else {
                                    _selectedInterests.add(subcategory);
                                  }
                                });
                              },
                              child: _InterestCard(
                                label: subcategory,
                                categoryName: currentCategory.name,
                                selected: isSelected,
                                width: (constraints.maxWidth - 12) / 2,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_selectedInterests.isNotEmpty)
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
                                '已选择 ${_selectedInterests.length} 个兴趣',
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
                    '完成',
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

class InterestCategory {
  final String id;
  final String name;
  final String emoji;
  final List<String> subcategories;

  InterestCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.subcategories,
  });
}

class _InterestCard extends StatelessWidget {
  final String label;
  final String categoryName;
  final bool selected;
  final double width;

  const _InterestCard({
    Key? key,
    required this.label,
    required this.categoryName,
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
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

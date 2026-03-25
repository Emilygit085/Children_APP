import 'package:flutter/material.dart';

class InterestCategorySelectionPage extends StatefulWidget {
  const InterestCategorySelectionPage({Key? key}) : super(key: key);

  @override
  State<InterestCategorySelectionPage> createState() => _InterestCategorySelectionPageState();
}

class _InterestCategorySelectionPageState extends State<InterestCategorySelectionPage> {
  final List<InterestCategory> _categories = [
    InterestCategory(id: 'sport', name: '运动户外', emoji: '⚽'),
    InterestCategory(id: 'craft', name: '手工制作', emoji: '✂️'),
    InterestCategory(id: 'reading', name: '阅读写作', emoji: '📚'),
    InterestCategory(id: 'music', name: '音乐世界', emoji: '🎵'),
    InterestCategory(id: 'art', name: '美术设计', emoji: '🎨'),
    InterestCategory(id: 'tech', name: '科技科创', emoji: '🔬'),
    InterestCategory(id: 'movie', name: '电影戏剧', emoji: '🎬'),
    InterestCategory(id: 'acgn', name: 'ACGN', emoji: '🎮'),
    InterestCategory(id: 'board', name: '棋牌桌游', emoji: '♟️'),
    InterestCategory(id: 'food', name: '美食烹饪', emoji: '🍳'),
    InterestCategory(id: 'animal', name: '动物植物', emoji: '🐶'),
    InterestCategory(id: 'life', name: '休闲生活', emoji: '🏖️'),
  ];

  final Set<String> _selectedCategories = {};

  void _handleCategorySelect(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  void _handleContinue() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请至少选择一个大类'),
          backgroundColor: colorScheme.secondary,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/interest-selection',
      arguments: _selectedCategories.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          '选择兴趣大类',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: colorScheme.surface,
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
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.onSecondaryContainer,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '先选择你感兴趣的大类，下一步我们会让你选择具体的小爱好！',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '🎯 选择你感兴趣的大类',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _categories.map((category) {
                            final bool isSelected = _selectedCategories.contains(category.id);
                            return GestureDetector(
                              onTap: () => _handleCategorySelect(category.id),
                              child: _CategoryCard(
                                label: '${category.emoji} ${category.name}',
                                selected: isSelected,
                                width: (constraints.maxWidth - 12) / 2,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_selectedCategories.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.tertiary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.tertiary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '已选择 ${_selectedCategories.length} 个大类',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onTertiaryContainer,
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
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
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

  InterestCategory({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final bool selected;
  final double width;

  const _CategoryCard({
    Key? key,
    required this.label,
    required this.selected,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = selected
        ? [colorScheme.primary, colorScheme.primaryContainer]
        : null;

    return Container(
      width: width.clamp(140, 260),
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: selected ? null : colorScheme.surfaceVariant,
        border: selected ? null : Border.all(color: colorScheme.outlineVariant),
        gradient: selected
            ? LinearGradient(
                colors: colors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selected
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

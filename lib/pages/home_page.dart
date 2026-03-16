import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/current_user.dart';
import '../widgets/friend_card.dart';
import '../widgets/screen_time_banner.dart';
import '../utils/navigation_helper.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  // 假数据：所有潜在好友（用于推荐）
  final List<User> _allPotentialFriends = [
    User(
      id: '1',
      name: '小明',
      avatar: 'assets/images/avatar1.png',
      age: 8,
      interests: ['⚽足球', '📱手游'],
      personality: ['外向开朗', '精力充沛'],
      location: '附近 500m',
      role: UserRole.child,
    ),
    User(
      id: '2',
      name: '小红',
      avatar: 'assets/images/avatar4.png',
      age: 7,
      interests: ['🎨传统绘画', '📙读小说'],
      personality: ['安静内向', '喜欢想象'],
      location: '附近 1km',
      role: UserRole.child,
    ),
    User(
      id: '3',
      name: '小刚',
      avatar: 'assets/images/avatar2.png',
      age: 9,
      interests: ['🧩乐高', '⚽足球'],
      personality: ['外向开朗', '勇于尝试'],
      location: '附近 800m',
      role: UserRole.child,
    ),
    User(
      id: '4',
      name: '小强',
      avatar: 'assets/images/avatar1.png',
      age: 8,
      interests: ['⚽足球', '📱手游', '🧩乐高'],
      personality: ['精力充沛', '乐观阳光'],
      location: '附近 600m',
      role: UserRole.child,
    ),
    User(
      id: '5',
      name: '小美',
      avatar: 'assets/images/avatar4.png',
      age: 7,
      interests: ['⚽足球', '🎨传统绘画'],
      personality: ['善良可亲', '细心爱心'],
      location: '附近 1.2km',
      role: UserRole.child,
    ),
    User(
      id: '6',
      name: '小乐',
      avatar: 'assets/images/avatar3.png',
      age: 8,
      interests: ['🧩乐高', '📙读小说', '📱手游'],
      personality: ['热爱思辨', '喜欢想象'],
      location: '附近 900m',
      role: UserRole.child,
    ),
    User(
      id: '7',
      name: '小文',
      avatar: 'assets/images/avatar3.png',
      age: 9,
      interests: ['📙读小说', '🎨传统绘画'],
      personality: ['善于观察', '安静内向'],
      location: '附近 1.5km',
      role: UserRole.child,
    ),
    User(
      id: '8',
      name: '小宇',
      avatar: 'assets/images/avatar2.png',
      age: 8,
      interests: ['📱手游', '⚽足球', '🧩乐高'],
      personality: ['外向开朗', '精力充沛'],
      location: '附近 700m',
      role: UserRole.child,
    ),
  ];

  // 假数据：已添加的好友列表
  final List<User> _friends = [
    User(
      id: '1',
      name: '小明',
      avatar: 'assets/images/avatar1.png',
      age: 8,
      interests: ['⚽足球', '📱手游'],
      personality: ['外向开朗', '精力充沛'],
      location: '附近 500m',
      role: UserRole.child,
    ),
    User(
      id: '2',
      name: '小红',
      avatar: 'assets/images/avatar4.png',
      age: 7,
      interests: ['🎨传统绘画', '📙读小说'],
      personality: ['安静内向', '喜欢想象'],
      location: '附近 1km',
      role: UserRole.child,
    ),
    User(
      id: '3',
      name: '小刚',
      avatar: 'assets/images/avatar2.png',
      age: 9,
      interests: ['🧩乐高', '⚽足球'],
      personality: ['外向开朗', '勇于尝试'],
      location: '附近 800m',
      role: UserRole.child,
    ),
  ];

  /// 计算共同兴趣数量
  int _calculateCommonInterests(User user1, User user2) {
    final set1 = user1.interests.toSet();
    final set2 = user2.interests.toSet();
    return set1.intersection(set2).length;
  }

  /// 获取推荐好友列表（基于共同兴趣）
  List<Map<String, dynamic>> _getRecommendedFriends() {
    final currentUser = CurrentUser.user;
    if (currentUser == null || currentUser.interests.isEmpty) {
      return [];
    }

    // 获取已添加的好友ID列表
    final friendIds = _friends.map((f) => f.id).toSet();

    // 过滤出未添加的好友，并计算共同兴趣
    final recommended = _allPotentialFriends
        .where((user) => !friendIds.contains(user.id))
        .map((user) {
      return {
        'user': user,
        'commonInterests': _calculateCommonInterests(currentUser, user),
      };
    }).toList();

    // 按共同兴趣数量从高到低排序
    recommended.sort((a, b) =>
        (b['commonInterests'] as int).compareTo(a['commonInterests'] as int));

    return recommended;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          '我的好友',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.purple[400],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              NavigationHelper.goToTab(context, NavigationHelper.profileTabIndex);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTimeBanner(),
            // 推荐好友区域
            Builder(
              builder: (context) {
                final recommended = _getRecommendedFriends();
                if (recommended.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🌟 推荐好友',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${recommended.length} 位',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...recommended.take(5).map((item) {
                        final user = item['user'] as User;
                        final commonInterests = item['commonInterests'] as int;
                        return FriendCard(
                          friend: user,
                          commonInterestsCount: commonInterests,
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
            // 好友列表
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '👥 我的好友',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.purple[200],
                      backgroundImage:
                          AssetImage(friend.avatar), // asset instead of network
                    ),
                    title: Text(
                      friend.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${friend.age}岁 · ${friend.location}'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: friend.interests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              backgroundColor: Colors.orange[100],
                              labelStyle: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      color: Colors.purple[400],
                      onPressed: () {
                        Navigator.pushNamed(context, '/chat',
                            arguments: friend);
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile',
                          arguments: friend);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationHelper.buildBottomNav(context, 0),
    );
  }
}

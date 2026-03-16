import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/current_user.dart';
import '../services/binding_service.dart';
import '../utils/navigation_helper.dart';
import '../widgets/screen_time_banner.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果传入了用户参数，显示该用户信息；否则显示当前用户信息
    final User? user = ModalRoute.of(context)?.settings.arguments as User?;
    final User? currentUser = CurrentUser.user;
    final User displayUser = user ??
        currentUser ??
        User(
          id: '0',
          name: '我',
          avatar: 'assets/images/avatar1.png',
          age: 8,
          interests: [],
          personality: [],
          location: '附近',
          role: UserRole.child,
        );
    final bool isCurrentUser = user == null;

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text(
          isCurrentUser ? '我的主页' : displayUser.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.purple[400],
        elevation: 0,
        leading: isCurrentUser
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // 智能返回：如果有 arguments（从其他页面进入），则 pop；否则切换到首页
                  NavigationHelper.smartPop(context, defaultRoute: '/home');
                },
              ),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ScreenTimeBanner(),
            // 头像和基本信息
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.purple[200],
                      backgroundImage: AssetImage(
                          displayUser.avatar), // asset instead of network
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayUser.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cake, color: Colors.white70, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${displayUser.age}岁',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        displayUser.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 兴趣标签
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 兴趣爱好',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: displayUser.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // 性格标签
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧠 性格特征',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: displayUser.personality.map((trait) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          trait,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // 如果是查看其他用户，显示操作按钮
            if (!isCurrentUser) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat',
                              arguments: displayUser);
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('发送消息'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已发送好友申请')),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('添加好友'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // 如果是当前用户，显示更多信息
            if (isCurrentUser) ...[
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text('我的活动'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    NavigationHelper.goToTab(context, 2);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(Icons.people, color: Colors.blue),
                  title: const Text('我的好友'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    NavigationHelper.goToTab(context, 0);
                  },
                ),
              ),
              const SizedBox(height: 12),
              //这边写了个判断，只有儿童端显示是否绑定家长
              if (displayUser.role == UserRole.child) ...[
                FutureBuilder<String?>(
                  future: CurrentUser.user != null
                      ? BindingService.instance
                          .getParentByChild(CurrentUser.user!.id)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    final boundParentId = snapshot.data;
                    final isBound = boundParentId != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isBound ? Icons.check_circle : Icons.link_off,
                          color: isBound ? Colors.green : Colors.orange,
                        ),
                        title: Text(isBound ? '已绑定家长' : '未绑定家长'),
                        subtitle: Text(
                          isBound ? '已与家长账号绑定' : '输入绑定码与家长账号绑定',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          if (isBound) {
                            // 已绑定，显示绑定信息
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已绑定家长账号'),
                              ),
                            );
                          } else {
                            // 未绑定，跳转到绑定码输入页面
                            Navigator.pushNamed(
                              context,
                              '/binding-code',
                              arguments: false, // isParent = false
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // 家长设置：仅家长端显示，儿童端不提供家长入口
                if (CurrentUser.isParent)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.family_restroom,
                          color: Colors.green),
                      title: const Text('家长设置'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        NavigationHelper.goToTab(context, 3);
                      },
                    ),
                  ),
                if (CurrentUser.isParent) const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: isCurrentUser
          ? NavigationHelper.buildBottomNav(
              context,
              NavigationHelper.profileTabIndex,
              selectedColor: Colors.purple[400],
            )
          : null,
    );
  }
}

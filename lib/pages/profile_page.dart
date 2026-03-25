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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          isCurrentUser ? '我的主页' : displayUser.name,
          style: textTheme.headlineSmall,
        ),
        backgroundColor: colorScheme.surface,
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
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.surface,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: colorScheme.secondaryContainer,
                      backgroundImage: AssetImage(
                          displayUser.avatar), // asset instead of network
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayUser.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cake, color: colorScheme.onSurfaceVariant, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${displayUser.age}岁',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, color: colorScheme.onSurfaceVariant, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        displayUser.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.onBackground,
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
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onTertiaryContainer,
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
                      color: colorScheme.onBackground,
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
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          trait,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
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
                  leading: Icon(Icons.favorite, color: colorScheme.error),
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
                  leading: Icon(Icons.people, color: colorScheme.primary),
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
                          color: isBound ? colorScheme.tertiary : colorScheme.secondary,
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
                      leading: Icon(Icons.family_restroom, color: colorScheme.tertiary),
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
              selectedColor: colorScheme.primary,
            )
          : null,
    );
  }
}

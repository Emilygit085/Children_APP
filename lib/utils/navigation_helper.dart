import 'package:flutter/material.dart';
import '../models/current_user.dart';

/// 导航辅助工具类
/// 用于处理 BottomNavigationBar 和 Navigator 混合使用的场景
class NavigationHelper {
  /// 安全返回：如果可以 pop 则 pop，否则导航到首页
  static void safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // 如果无法 pop，说明是通过 BottomNavigationBar 进入的，切换到首页
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// 检查当前页面是否可以通过 pop 返回
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// 智能返回：根据是否有 arguments 判断返回方式
  /// 如果有 arguments，说明是通过 pushNamed 进入的，应该 pop
  /// 如果没有 arguments，说明是通过 BottomNavigationBar 进入的，应该切换到首页
  ///
  /// 使用场景：
  /// - ChatPage: 从好友列表进入（有 arguments）应该 pop，从底部导航进入应该回首页
  /// - ProfilePage: 查看其他用户（有 arguments）应该 pop，查看自己应该回首页
  static void smartPop(BuildContext context, {String? defaultRoute}) {
    final route = ModalRoute.of(context);
    final hasArguments = route?.settings.arguments != null;

    if (hasArguments && Navigator.canPop(context)) {
      // 有参数且可以 pop，说明是通过 pushNamed 进入的
      Navigator.pop(context);
    } else {
      // 没有参数或无法 pop，说明是通过 BottomNavigationBar 进入的
      // 使用 pushReplacementNamed 避免栈积累
      Navigator.pushReplacementNamed(context, defaultRoute ?? '/home');
    }
  }

  /// 检查当前路由是否可以通过 pop 返回
  /// 用于决定是否显示返回按钮
  static bool shouldShowBackButton(BuildContext context) {
    final route = ModalRoute.of(context);
    final hasArguments = route?.settings.arguments != null;
    return hasArguments && Navigator.canPop(context);
  }

  /// 儿童端 4-tab 路由（无家长入口）
  static const List<String> _childRoutes = [
    '/home',
    '/chat',
    '/activity',
    '/profile',
  ];

  /// 家长端 5-tab 路由（含家长页）
  static const List<String> _parentRoutes = [
    '/home',
    '/chat',
    '/activity',
    '/parent',
    '/profile',
  ];

  /// 当前角色对应的 tab 路由列表
  static List<String> get _routes =>
      CurrentUser.isParent ? _parentRoutes : _childRoutes;

  /// 「我的」tab 的 index（儿童端 3，家长端 4）
  static int get profileTabIndex =>
      CurrentUser.isParent ? 4 : 3;

  /// 统一的 Tab 切换工具：按角色分流，儿童端无家长 tab
  static void goToTab(BuildContext context, int index) {
    final routes = _routes;
    if (index < 0 || index >= routes.length) return;
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  /// 儿童端 4-tab（首页/聊天/活动/我的）
  static const List<BottomNavigationBarItem> childTabItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: '聊天'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: '活动'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ];

  /// 家长端 5-tab（含家长）
  static const List<BottomNavigationBarItem> parentTabItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: '聊天'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: '活动'),
    BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: '家长'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ];

  /// 按角色构建底部导航栏
  static Widget buildBottomNav(
    BuildContext context,
    int currentIndex, {
    Color? selectedColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final items =
        CurrentUser.isParent ? parentTabItems : childTabItems;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: selectedColor ?? colorScheme.primary,
      type: BottomNavigationBarType.fixed,
      items: items,
      onTap: (index) => goToTab(context, index),
    );
  }
}

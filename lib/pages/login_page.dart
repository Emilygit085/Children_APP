import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/current_user.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  UserRole? _selectedRole;

  final AuthService _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    // 初始化数据库
    _initDatabase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 从路由参数获取选择的角色（在 didChangeDependencies 中安全访问 context）
    if (_selectedRole == null) {
      final role = ModalRoute.of(context)?.settings.arguments as UserRole?;
      _selectedRole = role;
    }
  }

  Future<void> _initDatabase() async {
    // 确保数据库已初始化
    await DatabaseHelper.instance.database;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('请输入用户名和密码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dbUser = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (dbUser == null) {
        _showError('用户名或密码错误');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 根据角色加载资料并设置当前用户
      await _loadUserProfile(dbUser);

      // 根据角色跳转
      if (dbUser.role == 'parent') {
        Navigator.pushReplacementNamed(context, '/parent');
      } else {
        // 检查是否已选择兴趣
        final childProfile = await _authService.getChildProfile(dbUser.id);
        if (childProfile == null || childProfile.interests.isEmpty) {
          Navigator.pushReplacementNamed(context, '/personality-selection');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      _showError('登录失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_selectedRole == null) {
      Navigator.pushReplacementNamed(context, '/role-select');
      return;
    }

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('请输入用户名和密码');
      return;
    }

    if (!_isLogin && _nameController.text.isEmpty) {
      _showError('请输入姓名');
      return;
    }

    if (_selectedRole == UserRole.child && _ageController.text.isEmpty) {
      _showError('请输入年龄');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dbUser = await _authService.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole == UserRole.parent ? 'parent' : 'child',
        parentName: _selectedRole == UserRole.parent
            ? _nameController.text.trim()
            : null,
        childName: _selectedRole == UserRole.child
            ? _nameController.text.trim()
            : null,
        age: _selectedRole == UserRole.child
            ? int.tryParse(_ageController.text)
            : null,
      );

      // 加载用户资料并设置当前用户
      await _loadUserProfile(dbUser);

      // 根据角色跳转
      if (dbUser.role == 'parent') {
        Navigator.pushReplacementNamed(context, '/parent');
      } else {
        Navigator.pushReplacementNamed(context, '/personality-selection');
      }
    } catch (e) {
      _showError('注册失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserProfile(dynamic dbUser) async {
    // 转换为 UI 使用的 User 模型
    UserRole role = dbUser.role == 'parent' ? UserRole.parent : UserRole.child;
    String name;
    int age;
    List<String> interests = [];
    List<String> personality = [];

    if (role == UserRole.parent) {
      final profile = await _authService.getParentProfile(dbUser.id);
      name = profile?.parentName ?? '家长';
      age = 35; // 默认年龄
    } else {
      final profile = await _authService.getChildProfile(dbUser.id);
      name = profile?.childName ?? '我';
      age = profile?.age ?? 8;
      interests = profile?.interests ?? [];
      personality = profile?.personality ?? [];
    }

    final user = User(
      id: dbUser.id,
      name: name,
      avatar: 'assets/images/avatar1.png',
      age: age,
      interests: interests,
      personality: personality,
      location: '附近',
      role: role,
    );

    CurrentUser.setUser(user);
    if (interests.isNotEmpty) {
      CurrentUser.setInterests(interests);
    }
  }

  void _showError(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  void _handleSubmit() {
    if (_isLogin) {
      _handleLogin();
    } else {
      _handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/头像区域
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.secondary, width: 3),
                  ),
                  child: const Icon(
                    Icons.child_care,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // 标题
                Text(
                  _isLogin ? '欢迎回来！' : '加入我们！',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 40),
                // 显示选择的角色
                if (_selectedRole != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedRole == UserRole.parent
                          ? colorScheme.tertiaryContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedRole == UserRole.parent
                          ? '👨‍👩‍👧 家长身份'
                          : '👶 儿童身份',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == UserRole.parent
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                if (_selectedRole == null)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/role-select');
                    },
                    child: const Text('请先选择身份'),
                  ),
                const SizedBox(height: 16),
                // 输入框
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: '用户名',
                      prefixIcon:
                          Icon(Icons.person, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '密码',
                      prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                // 注册时显示额外字段
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText:
                            _selectedRole == UserRole.parent ? '家长姓名' : '儿童姓名',
                        prefixIcon:
                            Icon(Icons.badge, color: colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),
                  ),
                  if (_selectedRole == UserRole.child) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '年龄',
                          prefixIcon:
                              Icon(Icons.cake, color: colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                // 登录/注册按钮
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? '登录' : '注册',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // 切换登录/注册
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin ? '还没有账号？立即注册' : '已有账号？立即登录',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

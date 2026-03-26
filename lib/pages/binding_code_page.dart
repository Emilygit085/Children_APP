import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/current_user.dart';
import '../services/binding_service.dart';
import '../services/auth_service.dart';

/// 绑定码生成/输入页面
class BindingCodePage extends StatefulWidget {
  final bool isParent; // true: 家长生成绑定码, false: 儿童输入绑定码

  const BindingCodePage({
    Key? key,
    required this.isParent,
  }) : super(key: key);

  @override
  State<BindingCodePage> createState() => _BindingCodePageState();
}

class _BindingCodePageState extends State<BindingCodePage> {
  String? _generatedCode;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  final BindingService _bindingService = BindingService.instance;
  final AuthService _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    // 如果是家长，尝试获取已有绑定码
    if (widget.isParent) {
      _loadExistingBindCode();
    }
  }

  Future<void> _loadExistingBindCode() async {
    final currentUser = CurrentUser.user;
    if (currentUser == null || !currentUser.isParent) return;

    try {
      final bindCode =
          await _bindingService.getOrGenerateBindCode(currentUser.id);
      setState(() {
        _generatedCode = bindCode;
      });
    } catch (e) {
      // 忽略错误，用户可以在页面上生成
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 生成绑定码（家长端）
  Future<void> _generateCode() async {
    final currentUser = CurrentUser.user;
    if (currentUser == null || !currentUser.isParent) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bindCode = await _bindingService.generateBindCode(currentUser.id);
      setState(() {
        _generatedCode = bindCode;
      });
    } catch (e) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成绑定码失败：${e.toString()}'),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 输入绑定码并绑定（儿童端）
  Future<void> _bindWithCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入6位绑定码'),
          backgroundColor: colorScheme.secondary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = CurrentUser.user;
      if (currentUser == null || !currentUser.isChild) {
        _showError('当前用户不是儿童用户');
        return;
      }

      final success =
          await _bindingService.bindChildToParent(currentUser.id, code);

      if (success) {
        // 绑定成功，更新当前用户的绑定信息
        final childProfile = await _authService.getChildProfile(currentUser.id);
        if (childProfile != null) {
          final updatedUser = CurrentUser.user!;
          CurrentUser.setUser(updatedUser);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('绑定成功！'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError('绑定码无效或已使用，请重新输入');
      }
    } catch (e) {
      _showError('绑定失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  /// 复制绑定码
  void _copyCode() {
    if (_generatedCode != null) {
      final colorScheme = Theme.of(context).colorScheme;
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已复制到剪贴板'),
          backgroundColor: colorScheme.tertiary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rolePrimary =
        widget.isParent ? colorScheme.tertiary : colorScheme.primary;
    final roleOnPrimary =
        widget.isParent ? colorScheme.onTertiary : colorScheme.onPrimary;
    final roleContainer = widget.isParent
        ? colorScheme.tertiaryContainer
        : colorScheme.primaryContainer;
    final roleOnContainer = widget.isParent
        ? colorScheme.onTertiaryContainer
        : colorScheme.onPrimaryContainer;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.isParent ? '生成绑定码' : '输入绑定码',
          style: textTheme.headlineSmall,
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isParent ? Icons.info_outline : Icons.qr_code,
                      color: roleOnContainer,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isParent
                            ? '生成绑定码后，让您的孩子输入此码即可完成绑定'
                            : '请输入家长提供的6位绑定码',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (widget.isParent) ...[
                // 家长端：生成绑定码
                if (_generatedCode == null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _generateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rolePrimary,
                        foregroundColor: roleOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '生成绑定码',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // 显示生成的绑定码
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '您的绑定码',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: roleContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: rolePrimary,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            _generatedCode!,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: roleOnContainer,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _copyCode,
                              icon: const Icon(Icons.copy),
                              label: const Text('复制'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rolePrimary,
                                foregroundColor: roleOnPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _generateCode,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重新生成'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.surfaceVariant,
                                foregroundColor: colorScheme.onSurfaceVariant,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '绑定码24小时内有效',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // 儿童端：输入绑定码
                Text(
                  '请输入6位绑定码',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      color: colorScheme.onSurface.withOpacity(0.24),
                      letterSpacing: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 3,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _bindWithCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rolePrimary,
                      foregroundColor: roleOnPrimary,
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
                              strokeWidth: 2.4,
                              color: roleOnPrimary,
                            ),
                          )
                        : const Text(
                            '确认绑定',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

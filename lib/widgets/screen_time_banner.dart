import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/screen_time_manager.dart';

/// 儿童端页面顶部的屏幕使用时间 Banner（仅 Demo）
class ScreenTimeBanner extends StatefulWidget {
  const ScreenTimeBanner({Key? key}) : super(key: key);

  @override
  State<ScreenTimeBanner> createState() => _ScreenTimeBannerState();
}

class _ScreenTimeBannerState extends State<ScreenTimeBanner> {
  late ScreenTimeManager _manager;
  late ScreenTimeState _state;
  StreamSubscription<ScreenTimeState>? _subscription;

  @override
  void initState() {
    super.initState();
    _manager = ScreenTimeManager.instance;
    _state = _manager.currentState;
    // 启动 Demo 计时器（幂等）
    _manager.start();
    _subscription = _manager.stream.listen((newState) {
      if (!mounted) return;
      setState(() {
        _state = newState;
      });
      if (newState.limitReached && !_manager.limitPageShown) {
        _manager.markLimitPageShown();
        // 进入应用内限制页
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamed('/screen-time-limit');
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usedMinutes = _state.used.inMinutes;
    final limitMinutes = _state.limit.inMinutes;
    final remaining =
        (_state.limit - _state.used).inMinutes.clamp(0, limitMinutes);

    final bool reached = _state.limitReached;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: reached
              ? [colorScheme.errorContainer, colorScheme.error]
              : [colorScheme.primary, colorScheme.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reached ? Icons.health_and_safety : Icons.watch_later,
              color: reached ? colorScheme.error : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康使用手机',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: reached
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reached
                      ? '今天已经达到 $limitMinutes 分钟的使用上限，休息一下眼睛吧～'
                      : '今天已使用 $usedMinutes 分钟 · 剩余 $remaining 分钟（每日上限 $limitMinutes 分钟）',
                  style: TextStyle(
                    fontSize: 12,
                    color: reached
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimary,
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../models/current_user.dart';
import '../models/user.dart';
import '../services/chat_service.dart';
import '../services/token_storage.dart';
import '../widgets/chat_bubble.dart';
import '../utils/navigation_helper.dart';
import '../widgets/screen_time_banner.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, dynamic>> _demoMessages = [
    {'message': '你好！你想一起踢足球吗？', 'isMe': false},
    {'message': '好啊！什么时候？', 'isMe': true},
    {'message': '周六下午怎么样？在公园里！', 'isMe': false},
    {'message': '太好了！我让我妈妈同意一下！', 'isMe': true},
    {'message': '好的，等你消息！😊', 'isMe': false},
  ];

  List<Map<String, dynamic>> _remoteMessages = [];
  bool _loadingRemote = false;
  WebSocketChannel? _ws;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapRemote();
    });
  }

  Future<void> _bootstrapRemote() async {
    if (!ChatService.instance.available || !mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final User? friend = args is User ? args : null;
    if (friend == null || CurrentUser.user == null) return;

    setState(() => _loadingRemote = true);
    try {
      _conversationId = await ChatService.instance.findConversationIdForPeer(friend.id);
      if (_conversationId != null) {
        final raw = await ChatService.instance.fetchMessages(_conversationId!);
        final me = CurrentUser.user!.id;
        _remoteMessages = raw.map((m) {
          return {
            'message': m['body'] as String,
            'isMe': m['sender_id'] == me,
          };
        }).toList();
      } else {
        _remoteMessages = [];
      }
      _connectWs();
    } catch (_) {
      _remoteMessages = [];
    } finally {
      if (mounted) setState(() => _loadingRemote = false);
    }
  }

  void _connectWs() {
    if (!ApiConfig.useRemoteApi) return;
    TokenStorage.instance.read().then((t) {
      if (t == null || !mounted) return;
      try {
        _ws = WebSocketChannel.connect(Uri.parse(ApiConfig.wsUrl(t)));
        _ws!.stream.listen((event) {
          if (!mounted) return;
          try {
            final j = jsonDecode(event as String) as Map<String, dynamic>;
            if (j['type'] == 'chat_message') {
              _bootstrapRemote();
            }
          } catch (_) {}
        });
      } catch (_) {}
    });
  }

  Future<void> _send(User? friend) async {
    final text = _inputController.text.trim();
    if (text.isEmpty || friend == null || CurrentUser.user == null) return;

    if (ChatService.instance.available) {
      setState(() => _loadingRemote = true);
      try {
        await ChatService.instance.sendMessage(friend.id, text);
        _inputController.clear();
        await _bootstrapRemote();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      } finally {
        if (mounted) setState(() => _loadingRemote = false);
      }
      return;
    }

    setState(() {
      _demoMessages.add({'message': text, 'isMe': true});
      _inputController.clear();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _ws?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final User? friend = ModalRoute.of(context)?.settings.arguments as User?;
    final String friendName = friend?.name ?? '好友';
    final String friendAvatar =
        friend?.avatar ?? 'assets/images/avatar1.png';
    const String myAvatar = 'assets/images/avatar1.png';

    final bool useRemote = ChatService.instance.available;
    final messages = useRemote ? _remoteMessages : _demoMessages;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.secondaryContainer,
              backgroundImage: AssetImage(friendAvatar),
            ),
            const SizedBox(width: 12),
            Text(
              friendName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            NavigationHelper.smartPop(context, defaultRoute: '/home');
          },
        ),
      ),
      body: Column(
        children: [
          const ScreenTimeBanner(),
          if (useRemote && _loadingRemote)
            const LinearProgressIndicator(minHeight: 2),
          if (useRemote)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '对方需为已注册账号；演示好友仅本地模式可用。',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(
                  message: msg['message'] as String,
                  isMe: msg['isMe'] as bool,
                  avatar: msg['isMe'] as bool ? myAvatar : friendAvatar,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _send(friend),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationHelper.buildBottomNav(
        context,
        1,
        selectedColor: colorScheme.primary,
      ),
    );
  }
}

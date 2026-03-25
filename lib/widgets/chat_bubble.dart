import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? avatar;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && avatar != null) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.secondaryContainer,
              backgroundImage: AssetImage(avatar!), // asset instead of network
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (isMe && avatar != null) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  AssetImage(avatar!), // asset image instead of network image
            ),
          ],
        ],
      ),
    );
  }
}

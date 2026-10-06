import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
        top: 6,
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 头像
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) _buildAvatar(),
              if (!isUser) const SizedBox(width: 8),
              Text(
                isUser ? '我' : 'AI 助手',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isUser) const SizedBox(width: 8),
              if (isUser) _buildAvatar(),
            ],
          ),
          const SizedBox(height: 6),
          // 消息内容
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser ? AppTheme.userBubbleGradient : null,
              color: isUser ? null : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
              ),
              border: isUser
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? AppTheme.primaryLight.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isStreaming && message.content.isEmpty
                ? _buildTypingIndicator()
                : Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
          ),
          // 时间戳
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final isUser = message.role == MessageRole.user;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: isUser
            ? AppTheme.userBubbleGradient
            : const LinearGradient(
                colors: [AppTheme.accent, AppTheme.primaryLight],
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isUser ? AppTheme.primaryLight : AppTheme.accent).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

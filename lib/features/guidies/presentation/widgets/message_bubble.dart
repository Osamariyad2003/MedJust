// lib/features/guidies/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../../data/models/guide_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(GuideContent)? onContentTap;

  const MessageBubble({super.key, required this.message, this.onContentTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context, isUser),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color:
                          isUser
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.relatedContent != null) ...[
                  const SizedBox(height: 8),
                  _buildRelatedContent(context, message.relatedContent!),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(context, isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return CircleAvatar(
      radius: 18,
      backgroundColor:
          isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.support_agent,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRelatedContent(BuildContext context, GuideContent content) {
    return InkWell(
      onTap: () => onContentTap?.call(content),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اضغط لعرض التفاصيل',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

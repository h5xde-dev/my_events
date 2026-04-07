import 'package:flutter/material.dart';
import 'package:my_events/data/chat_repository.dart';
import 'package:my_events/models/chat_message.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    super.key,
    required this.eventId,
    required this.userId,
    required this.chatRepository,
  });

  final String eventId;
  final String userId;
  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatMessage>>(
      stream: chatRepository.watchMessages(eventId),
      builder: (context, messagesSnapshot) {
        final messages = messagesSnapshot.data ?? const <ChatMessage>[];
        if (messages.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<DateTime?>(
          stream: chatRepository.watchLastReadAt(userId: userId, eventId: eventId),
          builder: (context, readSnapshot) {
            final lastReadAt = readSnapshot.data;
            final unreadCount = messages.where((m) {
              if (m.authorId == userId) return false;
              final createdAt = m.createdAt;
              if (createdAt == null) return false;
              if (lastReadAt == null) return true;
              return createdAt.isAfter(lastReadAt);
            }).length;
            if (unreadCount <= 0) return const SizedBox.shrink();
            final label = unreadCount > 99 ? '99+' : unreadCount.toString();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_events/data/chat_repository.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/chat_message.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.event});

  final Event event;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const double _historyPrefetchThreshold = 360;
  final _chatRepository = const ChatRepository();
  final _eventRepository = const EventRepository();
  final _auth = Auth();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final Map<String, String> _authorNames = {};
  final List<ChatMessage> _olderMessages = [];
  User? _currentUser;
  bool _isSending = false;
  bool _isLoadingOlder = false;
  bool _hasMoreOlder = true;
  bool _isTyping = false;
  bool _pendingLoadOlder = false;

  @override
  void initState() {
    super.initState();
    _initUser();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initUser() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  @override
  void dispose() {
    final user = _currentUser;
    if (user != null) {
      _chatRepository.setTyping(
        eventId: widget.event.id,
        userId: user.uid,
        isTyping: false,
      );
    }
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final user = _currentUser ?? await _auth.currentUser();
      if (user == null) return;

      await _chatRepository.sendMessage(
        eventId: widget.event.id,
        authorId: user.uid,
        text: text,
      );
      _textController.clear();
      await _setTyping(false);
      _focusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _setTyping(bool value) async {
    final user = _currentUser;
    if (user == null || _isTyping == value) return;
    _isTyping = value;
    await _chatRepository.setTyping(
      eventId: widget.event.id,
      userId: user.uid,
      isTyping: value,
    );
  }

  Future<void> _loadOlder(List<ChatMessage> merged) async {
    if (_isLoadingOlder || !_hasMoreOlder || merged.isEmpty) return;
    final oldest = merged.last.createdAt;
    if (oldest == null) {
      setState(() => _hasMoreOlder = false);
      return;
    }
    setState(() => _isLoadingOlder = true);
    try {
      final page = await _chatRepository.fetchOlderMessages(
        eventId: widget.event.id,
        startAfterCreatedAt: oldest,
      );
      final knownIds = {
        ...merged.map((m) => m.id),
        ..._olderMessages.map((m) => m.id),
      };
      final unique = page.where((m) => !knownIds.contains(m.id)).toList();
      setState(() {
        _olderMessages.addAll(unique);
        if (page.length < 40) _hasMoreOlder = false;
      });
    } finally {
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingOlder || !_hasMoreOlder) {
      return;
    }
    final position = _scrollController.position;
    final nearTop = position.pixels >=
        (position.maxScrollExtent - _historyPrefetchThreshold);
    if (!nearTop || _pendingLoadOlder) return;
    setState(() => _pendingLoadOlder = true);
  }

  Future<void> _markAsRead() async {
    final user = _currentUser;
    if (user == null) return;
    await _chatRepository.markEventAsRead(
      userId: user.uid,
      eventId: widget.event.id,
    );
  }

  Future<String> _resolveAuthorName(String uid) async {
    final cached = _authorNames[uid];
    if (cached != null) return cached;

    final profile = await _eventRepository.getProfile(uid);
    final resolved = (profile?['name'] as String?)?.trim();
    final name = (resolved == null || resolved.isEmpty) ? 'Участник' : resolved;
    _authorNames[uid] = name;
    return name;
  }

  Future<void> _showOwnMessageMenu(ChatMessage message) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Удалить'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'edit') {
      await _editMessage(message);
      return;
    }
    if (choice == 'delete') {
      await _deleteMessage(message);
    }
  }

  Future<void> _editMessage(ChatMessage message) async {
    final controller = TextEditingController(text: message.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать сообщение'),
        content: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Введите новый текст',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newText == null || newText.trim().isEmpty) return;
    final user = _currentUser;
    if (user == null) return;
    await _chatRepository.updateMessage(
      eventId: widget.event.id,
      messageId: message.id,
      authorId: user.uid,
      text: newText,
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final user = _currentUser;
    if (user == null) return;
    await _chatRepository.deleteMessage(
      eventId: widget.event.id,
      messageId: message.id,
      authorId: user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат: ${widget.event.title}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatRepository.watchMessages(widget.event.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Не удалось загрузить чат. Попробуйте позже.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  _markAsRead();
                  final mergedById = <String, ChatMessage>{
                    for (final item in messages) item.id: item,
                    for (final item in _olderMessages) item.id: item,
                  };
                  final merged = mergedById.values.toList()
                    ..sort((a, b) {
                      final aMs = a.createdAt?.millisecondsSinceEpoch ?? 0;
                      final bMs = b.createdAt?.millisecondsSinceEpoch ?? 0;
                      return bMs.compareTo(aMs);
                    });
                  if (_pendingLoadOlder) {
                    _pendingLoadOlder = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadOlder(merged);
                    });
                  }
                  if (merged.isEmpty) {
                    return const Center(
                      child: Text('Пока сообщений нет. Напишите первым!'),
                    );
                  }

                  final currentUid = _currentUser?.uid;
                  return Column(
                    children: [
                      if (currentUid != null)
                        StreamBuilder<int>(
                          stream: _chatRepository.watchTypingUsersCount(
                            eventId: widget.event.id,
                            excludeUserId: currentUid,
                          ),
                          builder: (context, typingSnapshot) {
                            final count = typingSnapshot.data ?? 0;
                            if (count <= 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                count == 1
                                    ? 'Кто-то печатает...'
                                    : '$count участников печатают...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          itemCount: merged.length + 1,
                          itemBuilder: (context, index) {
                            if (index == merged.length) {
                              if (!_hasMoreOlder) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child:
                                      Center(child: Text('История загружена')),
                                );
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: _isLoadingOlder
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Прокрутите вверх для истории'),
                                ),
                              );
                            }
                            final message = merged[index];
                            final isMine = currentUid == message.authorId;
                            return FutureBuilder<String>(
                              future: _resolveAuthorName(message.authorId),
                              builder: (context, authorSnapshot) {
                                final authorName = isMine
                                    ? 'Вы'
                                    : (authorSnapshot.data ?? 'Участник');
                                return _MessageBubble(
                                  message: message,
                                  isMine: isMine,
                                  authorName: authorName,
                                  onLongPress: isMine
                                      ? () => _showOwnMessageMenu(message)
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      onChanged: (value) => _setTyping(value.trim().isNotEmpty),
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.authorName,
    this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final String authorName;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final bgColor = isMine
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = Theme.of(context).colorScheme.onSurface;

    final createdAt = message.createdAt;
    final hh = createdAt?.hour.toString().padLeft(2, '0');
    final mm = createdAt?.minute.toString().padLeft(2, '0');
    final timeLabel = (hh != null && mm != null) ? '$hh:$mm' : '...';
    final edited = message.updatedAt != null;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authorName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    edited ? '$timeLabel (изм.)' : timeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

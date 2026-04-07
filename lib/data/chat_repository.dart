import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_events/models/chat_message.dart';

class ChatRepository {
  const ChatRepository();

  CollectionReference<Map<String, dynamic>> _messages(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('messages');
  }

  Stream<List<ChatMessage>> watchMessages(String eventId) {
    return _messages(eventId)
        .orderBy('createdAt', descending: true)
        .limit(40)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, eventId, doc.data()))
              .toList(),
        );
  }

  Future<List<ChatMessage>> fetchOlderMessages({
    required String eventId,
    required DateTime startAfterCreatedAt,
    int limit = 40,
  }) async {
    final snapshot = await _messages(eventId)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(startAfterCreatedAt)])
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => ChatMessage.fromMap(doc.id, eventId, doc.data()))
        .toList();
  }

  Future<void> sendMessage({
    required String eventId,
    required String authorId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _messages(eventId).add({
      'authorId': authorId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMessage({
    required String eventId,
    required String messageId,
    required String authorId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final ref = _messages(eventId).doc(messageId);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    if (snapshot.data()?['authorId'] != authorId) return;

    await ref.update({
      'text': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage({
    required String eventId,
    required String messageId,
    required String authorId,
  }) async {
    final ref = _messages(eventId).doc(messageId);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    if (snapshot.data()?['authorId'] != authorId) return;
    await ref.delete();
  }

  Stream<ChatMessage?> watchLastMessage(String eventId) {
    return _messages(eventId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return ChatMessage.fromMap(doc.id, eventId, doc.data());
    });
  }

  Future<void> markEventAsRead({
    required String userId,
    required String eventId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('eventReads')
        .doc(eventId)
        .set({
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DateTime?> watchLastReadAt({
    required String userId,
    required String eventId,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('eventReads')
        .doc(eventId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      final raw = data?['lastReadAt'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    });
  }

  Future<void> setTyping({
    required String eventId,
    required String userId,
    required bool isTyping,
  }) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('typing')
        .doc(userId)
        .set({
      'isTyping': isTyping,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int> watchTypingUsersCount({
    required String eventId,
    required String excludeUserId,
  }) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('typing')
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.where((doc) => doc.id != excludeUserId).length,
        );
  }
}

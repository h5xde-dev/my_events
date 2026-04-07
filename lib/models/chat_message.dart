import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.eventId,
    required this.authorId,
    required this.text,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String eventId;
  final String authorId;
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ChatMessage.fromMap(
    String id,
    String eventId,
    Map<String, dynamic> data,
  ) {
    return ChatMessage(
      id: id,
      eventId: eventId,
      authorId: (data['authorId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

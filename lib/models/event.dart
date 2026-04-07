import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String place;
  final String category;
  final DateTime? startsAt;
  final String? createdBy;
  final DateTime? createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.place = '',
    this.category = 'Общее',
    this.startsAt,
    this.createdBy,
    this.createdAt,
  });

  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      title: (data['title'] as String?) ?? 'Без названия',
      description: (data['description'] as String?) ?? '',
      imageAsset: (data['imageAsset'] as String?) ?? 'images/image_01.png',
      place: (data['place'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Общее',
      startsAt: _parseDate(data['startsAt']),
      createdBy: data['createdBy'] as String?,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageAsset': imageAsset,
      'place': place,
      'category': category,
      'startsAt': startsAt?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}


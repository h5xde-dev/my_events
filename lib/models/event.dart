import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String place;
  final String category;
  final DateTime? startsAt;
  final int priceTier;
  final double distanceKm;
  final int friendsGoing;
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
    this.priceTier = 1,
    this.distanceKm = 1.0,
    this.friendsGoing = 0,
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
      priceTier: _parseInt(data['priceTier']) ?? 1,
      distanceKm: _parseDouble(data['distanceKm']) ?? 1.0,
      friendsGoing: _parseInt(data['friendsGoing']) ?? 0,
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
      'priceTier': priceTier,
      'distanceKm': distanceKm,
      'friendsGoing': friendsGoing,
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

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}


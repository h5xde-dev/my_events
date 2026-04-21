import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:my_events/models/event.dart';

class EventPageResult {
  final List<Event> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;

  const EventPageResult({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
}

class EventRepository {
  const EventRepository();

  List<Event> getPopularEvents() {
    return const [
      Event(
        id: 'city-day',
        title: 'День города',
        description: 'Праздник в центре города',
        imageAsset: 'images/image_02.jpg',
        place: 'Центральная площадь',
        latitude: 55.751244,
        longitude: 37.618423,
        category: 'Город',
        priceTier: 1,
        distanceKm: 2.3,
        friendsGoing: 6,
      ),
      Event(
        id: 'fair',
        title: 'Ярмарка',
        description: 'Сезонные товары и еда',
        imageAsset: 'images/image_03.jpg',
        place: 'Старый парк',
        latitude: 55.760186,
        longitude: 37.618711,
        category: 'Маркет',
        priceTier: 2,
        distanceKm: 1.2,
        friendsGoing: 3,
      ),
      Event(
        id: 'coffee-evening',
        title: 'Кофе вечер',
        description: 'Нетворкинг и спикеры',
        imageAsset: 'images/image_04.jpg',
        place: 'Coffee Hall',
        latitude: 55.74453,
        longitude: 37.60512,
        category: 'Нетворкинг',
        priceTier: 1,
        distanceKm: 0.8,
        friendsGoing: 4,
      ),
      Event(
        id: 'tobacco-tasting',
        title: 'Дегустация табака',
        description: 'Лаунж и новые миксы',
        imageAsset: 'images/image_01.png',
        place: 'Smoke Lounge',
        latitude: 55.763399,
        longitude: 37.640287,
        category: 'Лаунж',
        priceTier: 3,
        distanceKm: 3.4,
        friendsGoing: 1,
      ),
    ];
  }

  Stream<List<Event>> watchEvents() {
    final fallback = getPopularEvents();
    return FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final remote = snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList();
      if (remote.isEmpty) return fallback;
      return [...remote, ...fallback];
    });
  }

  Future<EventPageResult> fetchEventsPage({
    int limit = 12,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items =
        snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data())).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : startAfter;
    final hasMore = snapshot.docs.length == limit;

    return EventPageResult(items: items, lastDoc: lastDoc, hasMore: hasMore);
  }

  Stream<List<Event>> watchEventsByIds(Set<String> ids) {
    if (ids.isEmpty) return Stream.value(const <Event>[]);
    return watchEvents().map(
      (events) => events.where((e) => ids.contains(e.id)).toList(),
    );
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String category,
    required String imageUrl,
    DateTime? startsAt,
    required String createdBy,
  }) async {
    final normalizedAddress = address.trim();
    await FirebaseFirestore.instance.collection('events').add({
      'title': title.trim(),
      'description': description.trim(),
      'place': normalizedAddress,
      'address': normalizedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'startsAt': startsAt?.toIso8601String(),
      'priceTier': 1,
      'distanceKm': 1.0,
      'friendsGoing': 0,
      'imageUrl': imageUrl.trim(),
      'imageAsset': 'images/image_01.png',
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String category,
    required String imageUrl,
    DateTime? startsAt,
  }) async {
    final normalizedAddress = address.trim();
    await FirebaseFirestore.instance.collection('events').doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
      'place': normalizedAddress,
      'address': normalizedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'startsAt': startsAt?.toIso8601String(),
      'imageUrl': imageUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveProfile({
    required String userId,
    required String name,
    required String bio,
  }) async {
    final authUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (authUid != userId) {
      debugPrint(
        'saveProfile skipped: authUid=$authUid targetUserId=$userId',
      );
      return;
    }
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name.trim(),
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchProfile(String userId) {
    final authUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (authUid != userId) {
      debugPrint(
        'watchProfile blocked: authUid=$authUid targetUserId=$userId',
      );
      return Stream.value(null);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((d) => d.data())
        .handleError((Object error, StackTrace stackTrace) {
      if (error is FirebaseException) {
        debugPrint(
          'watchProfile error (${error.code}): authUid=$authUid targetUserId=$userId message=${error.message}',
        );
      } else {
        debugPrint('watchProfile unknown error: $error');
      }
    });
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final authUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (authUid != userId) {
      debugPrint(
        'getProfile blocked: authUid=$authUid targetUserId=$userId',
      );
      return null;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.data();
  }
}

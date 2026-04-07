import 'package:cloud_firestore/cloud_firestore.dart';
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
        category: 'Город',
      ),
      Event(
        id: 'fair',
        title: 'Ярмарка',
        description: 'Сезонные товары и еда',
        imageAsset: 'images/image_03.jpg',
        place: 'Старый парк',
        category: 'Маркет',
      ),
      Event(
        id: 'coffee-evening',
        title: 'Кофе вечер',
        description: 'Нетворкинг и спикеры',
        imageAsset: 'images/image_04.jpg',
        place: 'Coffee Hall',
        category: 'Нетворкинг',
      ),
      Event(
        id: 'tobacco-tasting',
        title: 'Дегустация табака',
        description: 'Лаунж и новые миксы',
        imageAsset: 'images/image_01.png',
        place: 'Smoke Lounge',
        category: 'Лаунж',
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
    required String place,
    required String category,
    DateTime? startsAt,
    required String createdBy,
  }) async {
    await FirebaseFirestore.instance.collection('events').add({
      'title': title.trim(),
      'description': description.trim(),
      'place': place.trim(),
      'category': category,
      'startsAt': startsAt?.toIso8601String(),
      'imageAsset': 'images/image_01.png',
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String description,
    required String place,
    required String category,
    DateTime? startsAt,
  }) async {
    await FirebaseFirestore.instance.collection('events').doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
      'place': place.trim(),
      'category': category,
      'startsAt': startsAt?.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveProfile({
    required String userId,
    required String name,
    required String bio,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name.trim(),
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchProfile(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((d) => d.data());
  }
}


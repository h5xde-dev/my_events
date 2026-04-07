import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/notifications_service.dart';

class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = <String>{};
  String? _userId;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String eventId) => _ids.contains(eventId);

  Future<void> bindUser(String? userId) async {
    _userId = userId;
    _ids.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    for (final doc in snapshot.docs) {
      _ids.add(doc.id);
    }
    notifyListeners();
  }

  Future<void> toggle(String eventId) async {
    final userId = _userId;
    if (userId == null) return;
    if (_ids.contains(eventId)) {
      _ids.remove(eventId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(eventId)
          .delete();
      await AnalyticsService.logFavoriteToggle(isFavorite: false);
    } else {
      _ids.add(eventId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(eventId)
          .set({'createdAt': FieldValue.serverTimestamp()});
      await AnalyticsService.logFavoriteToggle(isFavorite: true);
      await NotificationsService.scheduleLocalReminder(
        id: eventId.hashCode,
        title: 'Добавлено в избранное',
        body: 'Мы напомним вам об этом событии.',
      );
    }
    notifyListeners();
  }
}


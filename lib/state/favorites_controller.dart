import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/notifications_service.dart';
import 'package:my_events/data/user_stats_repository.dart';

class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = <String>{};
  String? _userId;
  final _statsRepo = const UserStatsRepository();

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String eventId) => _ids.contains(eventId);

  Future<void> bindUser(String? userId) async {
    _userId = userId;
    _ids.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    // Avoid reading user-scoped data before Firebase Auth finishes attaching
    // the current user/token to Firestore requests.
    final authUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (authUid != userId) {
      notifyListeners();
      return;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final retryAuthUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (retryAuthUid != userId) {
        notifyListeners();
        return;
      }
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
    }
    for (final doc in snapshot.docs) {
      _ids.add(doc.id);
    }

    // Keep derived stats in sync for the first render after login.
    await _statsRepo.syncFavoritesCount(
      userId: userId,
      favoritesCount: _ids.length,
    );

    notifyListeners();
  }

  Future<void> toggle(String eventId) async {
    final userId = _userId;
    if (userId == null) return;

    final now = DateTime.now();
    if (_ids.contains(eventId)) {
      _ids.remove(eventId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(eventId)
          .delete();
      await AnalyticsService.logFavoriteToggle(isFavorite: false);
      await _statsRepo.onFavoriteToggled(
        userId: userId,
        isAdding: false,
        at: now,
      );
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

      await _statsRepo.onFavoriteToggled(
        userId: userId,
        isAdding: true,
        at: now,
      );
    }
    notifyListeners();
  }
}

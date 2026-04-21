import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_events/models/user_stats.dart';

class UserStatsRepository {
  const UserStatsRepository();

  static const _favoritesFirstBadge = 'first_favorite';
  static const _favorites5Badge = 'five_favorites';
  static const _favorites10Badge = 'ten_favorites';
  static const _favorites20Badge = 'twenty_favorites';

  static const _streak3Badge = 'streak_3';
  static const _streak7Badge = 'streak_7';

  static const _firstEventBadge = 'first_event_created';

  String _dayKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    String pad2(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${pad2(d.month)}-${pad2(d.day)}';
  }

  DateTime? _parseDayKey(String? key) {
    if (key == null) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  List<String> _computeBadges({
    required int favoritesCount,
    required int eventsCreatedCount,
    required int streakLength,
  }) {
    final badges = <String>[];

    if (favoritesCount >= 1) badges.add(_favoritesFirstBadge);
    if (favoritesCount >= 5) badges.add(_favorites5Badge);
    if (favoritesCount >= 10) badges.add(_favorites10Badge);
    if (favoritesCount >= 20) badges.add(_favorites20Badge);

    if (eventsCreatedCount >= 1) badges.add(_firstEventBadge);

    if (streakLength >= 3) badges.add(_streak3Badge);
    if (streakLength >= 7) badges.add(_streak7Badge);

    return badges;
  }

  List<String> _readExistingBadges(Map<String, dynamic> data) {
    final raw = data['earnedBadges'];
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return <String>[];
  }

  List<String> _mergeBadges({
    required List<String> existing,
    required List<String> potential,
  }) {
    final set = <String>{...existing, ...potential};
    return set.toList(growable: false);
  }

  Future<UserStats> fetchStats(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return UserStats.empty;
    return UserStats.fromMap(data);
  }

  Future<void> syncFavoritesCount({
    required String userId,
    required int favoritesCount,
  }) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final ref = FirebaseFirestore.instance.collection('users').doc(userId);
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      final currentEventsCreatedCount =
          (data['eventsCreatedCount'] as num?)?.toInt() ?? 0;
      final currentStreakLength = (data['streakLength'] as num?)?.toInt() ?? 0;

      final existingBadges = _readExistingBadges(data);
      final potentialBadges = _computeBadges(
        favoritesCount: favoritesCount,
        eventsCreatedCount: currentEventsCreatedCount,
        streakLength: currentStreakLength,
      );

      tx.set(
          ref,
          {
            'favoritesCount': favoritesCount,
            'earnedBadges': _mergeBadges(
              existing: existingBadges,
              potential: potentialBadges,
            ),
          },
          SetOptions(merge: true));
    });
  }

  Future<void> onFavoriteToggled({
    required String userId,
    required bool isAdding,
    required DateTime at,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final dayKey = _dayKey(at);

    await firestore.runTransaction((tx) async {
      final ref = firestore.collection('users').doc(userId);
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      final currentFavoritesCount =
          (data['favoritesCount'] as num?)?.toInt() ?? 0;
      final currentEventsCreatedCount =
          (data['eventsCreatedCount'] as num?)?.toInt() ?? 0;
      final currentStreakLength = (data['streakLength'] as num?)?.toInt() ?? 0;
      final lastActivityDayKey = data['lastActivityDayKey'] as String?;
      final existingBadges = _readExistingBadges(data);

      final newFavoritesCount = isAdding
          ? currentFavoritesCount + 1
          : (currentFavoritesCount - 1).clamp(0, 1 << 31);

      var nextStreakLength = currentStreakLength;
      var nextLastActivityDayKey = lastActivityDayKey;

      // Streak increases only on "add to favorites" (engagement).
      if (isAdding) {
        final today = DateTime(at.year, at.month, at.day);
        final last = _parseDayKey(lastActivityDayKey);
        if (last == null || last.toIso8601String() != today.toIso8601String()) {
          final diffDays = last == null
              ? null
              : today
                  .difference(DateTime(last.year, last.month, last.day))
                  .inDays;

          if (diffDays == 1) {
            nextStreakLength = currentStreakLength + 1;
          } else if (diffDays == 0) {
            nextStreakLength = currentStreakLength;
          } else {
            nextStreakLength = 1;
          }
          nextLastActivityDayKey = dayKey;
        }
      }

      final potentialBadges = _computeBadges(
        favoritesCount: newFavoritesCount,
        eventsCreatedCount: currentEventsCreatedCount,
        streakLength: nextStreakLength,
      );

      final earnedBadges = _mergeBadges(
        existing: existingBadges,
        potential: potentialBadges,
      );

      tx.set(
          ref,
          {
            'favoritesCount': newFavoritesCount,
            'streakLength': nextStreakLength,
            'lastActivityDayKey': nextLastActivityDayKey,
            'earnedBadges': earnedBadges,
          },
          SetOptions(merge: true));
    });
  }

  Future<void> onMaybeGo({
    required String userId,
    required DateTime at,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final dayKey = _dayKey(at);

    await firestore.runTransaction((tx) async {
      final ref = firestore.collection('users').doc(userId);
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      final currentFavoritesCount =
          (data['favoritesCount'] as num?)?.toInt() ?? 0;
      final currentEventsCreatedCount =
          (data['eventsCreatedCount'] as num?)?.toInt() ?? 0;
      final currentStreakLength = (data['streakLength'] as num?)?.toInt() ?? 0;
      final lastActivityDayKey = data['lastActivityDayKey'] as String?;
      final existingBadges = _readExistingBadges(data);

      var nextStreakLength = currentStreakLength;
      var nextLastActivityDayKey = lastActivityDayKey;

      final today = DateTime(at.year, at.month, at.day);
      final last = _parseDayKey(lastActivityDayKey);
      final isSameDay = last != null &&
          last.year == today.year &&
          last.month == today.month &&
          last.day == today.day;

      if (!isSameDay) {
        if (last == null) {
          nextStreakLength = 1;
        } else {
          final diffDays = today
              .difference(DateTime(last.year, last.month, last.day))
              .inDays;
          if (diffDays == 1) {
            nextStreakLength = currentStreakLength + 1;
          } else {
            nextStreakLength = 1;
          }
        }
        nextLastActivityDayKey = dayKey;
      }

      final potentialBadges = _computeBadges(
        favoritesCount: currentFavoritesCount,
        eventsCreatedCount: currentEventsCreatedCount,
        streakLength: nextStreakLength,
      );

      final earnedBadges = _mergeBadges(
        existing: existingBadges,
        potential: potentialBadges,
      );

      tx.set(
          ref,
          {
            'streakLength': nextStreakLength,
            'lastActivityDayKey': nextLastActivityDayKey,
            'earnedBadges': earnedBadges,
          },
          SetOptions(merge: true));
    });
  }

  Future<void> onEventCreated({
    required String userId,
    required DateTime at,
  }) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.runTransaction((tx) async {
      final ref = firestore.collection('users').doc(userId);
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      final currentFavoritesCount =
          (data['favoritesCount'] as num?)?.toInt() ?? 0;
      final currentEventsCreatedCount =
          (data['eventsCreatedCount'] as num?)?.toInt() ?? 0;
      final currentStreakLength = (data['streakLength'] as num?)?.toInt() ?? 0;
      final existingBadges = _readExistingBadges(data);

      final newEventsCreatedCount = currentEventsCreatedCount + 1;

      // Keep streak for engagement with events "going" / favorites,
      // but we still update badges from eventsCreatedCount.
      final potentialBadges = _computeBadges(
        favoritesCount: currentFavoritesCount,
        eventsCreatedCount: newEventsCreatedCount,
        streakLength: currentStreakLength,
      );

      final earnedBadges = _mergeBadges(
        existing: existingBadges,
        potential: potentialBadges,
      );

      tx.set(
          ref,
          {
            'eventsCreatedCount': newEventsCreatedCount,
            'earnedBadges': earnedBadges,
          },
          SetOptions(merge: true));
    });
  }
}

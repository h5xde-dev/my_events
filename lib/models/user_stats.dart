class UserStats {
  const UserStats({
    required this.favoritesCount,
    required this.eventsCreatedCount,
    required this.streakLength,
    required this.lastActivityDayKey,
    required this.earnedBadges,
  });

  final int favoritesCount;
  final int eventsCreatedCount;
  final int streakLength;

  /// Key in format `yyyy-MM-dd` (local day).
  final String? lastActivityDayKey;
  final List<String> earnedBadges;

  static const empty = UserStats(
    favoritesCount: 0,
    eventsCreatedCount: 0,
    streakLength: 0,
    lastActivityDayKey: null,
    earnedBadges: <String>[],
  );

  factory UserStats.fromMap(Map<String, dynamic> map) {
    int readInt(String key) {
      final v = map[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return 0;
    }

    final badgesRaw = map['earnedBadges'];
    final badges = (badgesRaw is List)
        ? badgesRaw.whereType<String>().toList(growable: false)
        : <String>[];

    return UserStats(
      favoritesCount: readInt('favoritesCount'),
      eventsCreatedCount: readInt('eventsCreatedCount'),
      streakLength: readInt('streakLength'),
      lastActivityDayKey: map['lastActivityDayKey'] as String?,
      earnedBadges: badges,
    );
  }
}

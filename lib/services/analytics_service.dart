import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  static Future<void> logCreateEvent({required String category}) async {
    await _analytics.logEvent(
      name: 'create_event',
      parameters: {'category': category},
    );
  }

  static Future<void> logFavoriteToggle({required bool isFavorite}) async {
    await _analytics.logEvent(
      name: 'favorite_toggle',
      parameters: {'is_favorite': isFavorite ? 1 : 0},
    );
  }

  static Future<void> logSearchUsed({required String query}) async {
    await _analytics.logSearch(searchTerm: query);
  }
}

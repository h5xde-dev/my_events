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

  static Future<void> logSlotViewed({
    required String slotType,
    required int items,
  }) async {
    await _analytics.logEvent(
      name: 'slot_viewed',
      parameters: {'slot_type': slotType, 'items': items},
    );
  }

  static Future<void> logFriendProofOpened({required String eventId}) async {
    await _analytics.logEvent(
      name: 'friend_proof_opened',
      parameters: {'event_id': eventId},
    );
  }

  static Future<void> logPostEventCompleted({
    required String eventId,
    required int nextOptions,
  }) async {
    await _analytics.logEvent(
      name: 'post_event_completed',
      parameters: {'event_id': eventId, 'next_options': nextOptions},
    );
  }

  static Future<void> logNextEventTapped({
    required String sourceEventId,
    required String targetEventId,
  }) async {
    await _analytics.logEvent(
      name: 'next_event_tapped',
      parameters: {
        'source_event_id': sourceEventId,
        'target_event_id': targetEventId,
      },
    );
  }
}

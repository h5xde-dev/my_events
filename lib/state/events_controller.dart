import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/event.dart';

class EventSlotRecommendation {
  final Event event;
  final String reason;
  final double score;

  const EventSlotRecommendation({
    required this.event,
    required this.reason,
    required this.score,
  });
}

class EventsController extends ChangeNotifier {
  EventsController({EventRepository? repository})
      : _repository = repository ?? const EventRepository() {
    _events = _repository.getPopularEvents();
  }

  final EventRepository _repository;
  List<Event> _events = const [];
  bool _isLoading = false; // initial loading
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  StreamSubscription<List<Event>>? _fallbackSubscription;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  List<EventSlotRecommendation> smartWeekRecommendations({
    int maxItems = 7,
    int budgetTier = 2,
  }) {
    final now = DateTime.now();
    final weekAhead = now.add(const Duration(days: 7));
    final withScore = _events
        .where((event) {
          final startsAt = event.startsAt;
          return startsAt != null &&
              startsAt.isAfter(now.subtract(const Duration(hours: 2))) &&
              startsAt.isBefore(weekAhead);
        })
        .map((event) {
          final score = _scoreEvent(event: event, now: now, budgetTier: budgetTier);
          return EventSlotRecommendation(
            event: event,
            reason: _buildReason(event),
            score: score,
          );
        })
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (withScore.isEmpty) {
      return _events
          .take(maxItems)
          .map(
            (event) => EventSlotRecommendation(
              event: event,
              reason: _buildReason(event),
              score: _scoreEvent(event: event, now: now, budgetTier: budgetTier),
            ),
          )
          .toList();
    }
    return withScore.take(maxItems).toList();
  }

  List<EventSlotRecommendation> betweenClassesRecommendations({
    int maxItems = 4,
    int budgetTier = 2,
  }) {
    final now = DateTime.now();
    final inNinetyMinutes = now.add(const Duration(minutes: 90));
    final candidates = _events
        .where((event) {
          final startsAt = event.startsAt;
          if (startsAt == null) return false;
          return startsAt.isAfter(now.subtract(const Duration(minutes: 15))) &&
              startsAt.isBefore(inNinetyMinutes);
        })
        .map((event) {
          final score = _scoreEvent(event: event, now: now, budgetTier: budgetTier) + 0.5;
          return EventSlotRecommendation(
            event: event,
            reason: 'Подходит в окно между парами',
            score: score,
          );
        })
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (candidates.isEmpty) {
      return smartWeekRecommendations(maxItems: maxItems, budgetTier: budgetTier);
    }
    return candidates.take(maxItems).toList();
  }

  void start() {
    if (_events.isNotEmpty || _isLoading) return;
    unawaited(loadInitial());
  }

  Future<void> loadInitial() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repository.fetchEventsPage();
      _events = page.items;
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;

      if (_events.isEmpty) {
        _fallbackSubscription ??= _repository.watchEvents().listen((items) {
          _events = items;
          notifyListeners();
        });
      }
    } catch (e) {
      _error = e.toString();
      _events = _repository.getPopularEvents();
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.fetchEventsPage(startAfter: _lastDoc);
      _events = [..._events, ...page.items];
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void stop() {
    _fallbackSubscription?.cancel();
    _fallbackSubscription = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  double _scoreEvent({
    required Event event,
    required DateTime now,
    required int budgetTier,
  }) {
    final startsAt = event.startsAt;
    final hoursToStart = startsAt == null ? 24.0 : startsAt.difference(now).inMinutes / 60;
    final recencyScore = (24 - hoursToStart.clamp(0, 24)) / 24;
    final budgetScore = 1 - ((event.priceTier - budgetTier).abs() / 3);
    final distanceScore = 1 - (event.distanceKm.clamp(0, 8) / 8);
    final socialScore = (event.friendsGoing.clamp(0, 8)) / 8;
    return (recencyScore * 0.35) +
        (budgetScore * 0.3) +
        (distanceScore * 0.25) +
        (socialScore * 0.1);
  }

  String _buildReason(Event event) {
    final budget = event.priceTier <= 1
        ? 'бюджетно'
        : event.priceTier == 2
            ? 'средний чек'
            : 'премиум';
    return '${event.distanceKm.toStringAsFixed(1)} км, $budget, ${event.friendsGoing} друзей уже идут';
  }
}


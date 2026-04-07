import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/event.dart';

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
}


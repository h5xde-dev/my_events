import 'package:flutter/foundation.dart';

class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = <String>{};

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String eventId) => _ids.contains(eventId);

  void toggle(String eventId) {
    if (_ids.contains(eventId)) {
      _ids.remove(eventId);
    } else {
      _ids.add(eventId);
    }
    notifyListeners();
  }
}


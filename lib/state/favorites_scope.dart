import 'package:flutter/widgets.dart';
import 'package:my_events/state/favorites_controller.dart';

class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    super.key,
    required FavoritesController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static FavoritesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope not found in widget tree');
    return scope!.notifier!;
  }
}

import 'package:flutter/widgets.dart';
import 'package:my_events/state/events_controller.dart';

class EventsScope extends InheritedNotifier<EventsController> {
  const EventsScope({
    super.key,
    required EventsController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static EventsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EventsScope>();
    assert(scope != null, 'EventsScope not found in widget tree');
    return scope!.notifier!;
  }
}

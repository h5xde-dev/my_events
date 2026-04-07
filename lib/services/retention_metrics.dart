class RetentionMetricsTargets {
  const RetentionMetricsTargets._();

  // Product targets for the first retention iteration.
  static const double d7Retention = 0.28;
  static const double d30Retention = 0.14;
  static const double wauMau = 0.52;
  static const double sessions2plusPerWeek = 0.45;
}

class RetentionEvents {
  const RetentionEvents._();

  static const String slotViewed = 'slot_viewed';
  static const String friendProofOpened = 'friend_proof_opened';
  static const String postEventCompleted = 'post_event_completed';
  static const String nextEventTapped = 'next_event_tapped';
}

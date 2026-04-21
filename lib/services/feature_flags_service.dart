import 'package:firebase_remote_config/firebase_remote_config.dart';

class FeatureFlagsService {
  FeatureFlagsService._();

  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;
  static bool _initialized = false;

  static bool get smartWeekEnabled =>
      _remoteConfig.getBool('ff_smart_week_enabled');
  static bool get betweenClassesEnabled =>
      _remoteConfig.getBool('ff_between_classes_enabled');
  static bool get socialProofEnabled =>
      _remoteConfig.getBool('ff_social_proof_enabled');
  static bool get postEventFlowEnabled =>
      _remoteConfig.getBool('ff_post_event_flow_enabled');

  static Future<void> init() async {
    if (_initialized) return;
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults(const {
      'ff_smart_week_enabled': true,
      'ff_between_classes_enabled': true,
      'ff_social_proof_enabled': true,
      'ff_post_event_flow_enabled': true,
    });
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults if network is unavailable.
    }
    _initialized = true;
  }
}

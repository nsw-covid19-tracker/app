import 'firebase_config_stub.dart'
    if (dart.library.io) 'firebase_config_mobile.dart'
    if (dart.library.html) 'firebase_config_web.dart';

abstract class FirebaseConfig {
  static FirebaseConfig _instance;

  static FirebaseConfig get instance {
    _instance ??= getConfig();
    return _instance;
  }

  Future<void> init();
}

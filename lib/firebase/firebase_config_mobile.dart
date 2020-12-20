import 'package:firebase_core/firebase_core.dart';
import 'package:nsw_covid_tracker/firebase/firebase_config.dart';

FirebaseConfig getConfig() => FirebaseConfigMobile();

class FirebaseConfigMobile extends FirebaseConfig {
  @override
  Future<void> init() async {
    await Firebase.initializeApp();
  }
}

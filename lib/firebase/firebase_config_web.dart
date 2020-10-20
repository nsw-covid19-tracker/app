import 'package:nsw_covid_tracker/firebase/firebase_config.dart';
import 'package:firebase/firebase.dart' as fb;

FirebaseConfig getConfig() => FirebaseConfigWeb();

class FirebaseConfigWeb extends FirebaseConfig {
  @override
  Future<void> init() async {
    fb.initializeApp(
      apiKey: 'AIzaSyDwLVOdCNmfUPSCumSmVD5DRs7vEgAl3ro',
      authDomain: 'nsw-covid-tracker.firebaseapp.com',
      databaseURL: 'https://nsw-covid-tracker.firebaseio.com',
      projectId: 'nsw-covid-tracker',
      storageBucket: 'nsw-covid-tracker.appspot.com',
    );
  }
}

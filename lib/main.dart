import 'package:bloc/bloc.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:nsw_covid_tracker/app.dart';
import 'package:nsw_covid_tracker/bloc_observer.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    fb.initializeApp(
      apiKey: 'AIzaSyDwLVOdCNmfUPSCumSmVD5DRs7vEgAl3ro',
      authDomain: 'nsw-covid-tracker.firebaseapp.com',
      databaseURL: 'https://nsw-covid-tracker.firebaseio.com',
      projectId: 'nsw-covid-tracker',
      storageBucket: 'nsw-covid-tracker.appspot.com',
    );
  } else {
    await Firebase.initializeApp();
    await FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = MyBlocObserver();
  runApp(App(HomeRepo()));
}

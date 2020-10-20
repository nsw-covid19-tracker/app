import 'package:bloc/bloc.dart';
import 'package:nsw_covid_tracker/app.dart';
import 'package:nsw_covid_tracker/bloc_observer.dart';
import 'package:nsw_covid_tracker/firebase/firebase_config.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.instance.init();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = MyBlocObserver();
  runApp(App(HomeRepo()));
}

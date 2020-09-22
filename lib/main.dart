import 'package:bloc/bloc.dart';
import 'package:covid_tracing/app.dart';
import 'package:covid_tracing/bloc_observer.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = MyBlocObserver();
  runApp(App(HomeRepo()));
}

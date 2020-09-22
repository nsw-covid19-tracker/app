import 'package:bloc/bloc.dart';
import 'package:covid_tracing/app.dart';
import 'package:covid_tracing/bloc_observer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = MyBlocObserver();
  runApp(App());
}

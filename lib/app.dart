import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/home.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends MaterialApp {
  final HomeRepo homeRepo;

  App(this.homeRepo)
      : super(
          home: BlocProvider(
            create: (context) => HomeBloc(homeRepo),
            child: HomePage(),
          ),
        );
}

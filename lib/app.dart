import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/home.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:equatable/equatable.dart';

part 'home_bloc.g.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo _homeRepo;

  HomeBloc(this._homeRepo) : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchAll) {
      yield* _mapFetchAllToState(event);
    } else if (event is SearchLocations) {
      yield* _mapSearchLocationToState(event);
    }
  }

  Stream<HomeState> _mapFetchAllToState(FetchAll event) async* {
    final currState = state;
    if (currState is HomeInitial) {
      try {
        final cases = await _homeRepo.fetchCases();
        final newState = HomeSuccess(cases: cases);
        yield newState;
        final locations = await _homeRepo.fetchLocations();
        yield newState.copyWith(locations: locations);
      } catch (_) {
        yield HomeFailure();
      }
    }
  }

  Stream<HomeState> _mapSearchLocationToState(SearchLocations event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      try {
        final locations = List<Location>.from(currState.locations);
        final query = event.query.toLowerCase();
        var results = <Location>[];

        if (query.isNotEmpty) {
          results = locations
              .where((element) =>
                  element.postcode.toLowerCase().contains(query) ||
                  element.suburb.toLowerCase().contains(query))
              .take(5)
              .toList();
        }

        yield currState.copyWith(locationsResult: results);
      } catch (_) {
        yield HomeFailure();
      }
    }
  }
}

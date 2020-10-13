import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:covid_tracing/home/common/consts.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
      yield* _mapSearchLocationsToState(event);
    } else if (event is FilterCasesByPostcode) {
      yield* _mapFilterCasesByPostcodeToState(event);
    } else if (event is ClearFilteredCases) {
      yield* _mapClearFilteredCasesToState(event);
    } else if (event is FilterCasesByExpiry) {
      yield* _mapFilterCasesByExpiryToState(event);
    } else if (event is FilterCasesByDates) {
      yield* _mapFilterCasesByDatesToState(event);
    } else if (event is EmptyActiveCasesHandled) {
      yield* _mapEmptyActiveCasesHandledToState(event);
    } else if (event is SortCases) {
      yield* _mapSortCasesToState(event);
    } else if (event is SortCasesHandled) {
      yield* _mapSortCasesHandledToState(event);
    }
  }

  Stream<HomeState> _mapFetchAllToState(FetchAll event) async* {
    final currState = state;
    if (currState is HomeInitial) {
      try {
        final cases = await _homeRepo.fetchCases();
        final activeCases =
            cases.where((myCase) => (!myCase.isExpired)).toList();
        final newState = HomeSuccess(
          cases: cases,
          casesResult: activeCases,
          isEmptyActiveCases: activeCases.isEmpty,
        );
        yield newState;
        final locations = await _homeRepo.fetchLocations();
        yield newState.copyWith(locations: locations);
      } catch (_) {
        yield HomeFailure();
      }
    }
  }

  Stream<HomeState> _mapSearchLocationsToState(SearchLocations event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final locations = List<Location>.from(currState.locations);
      final query = event.query.toLowerCase();
      var results = <Location>[];

      if (query.isNotEmpty) {
        results = locations
            .where((element) =>
                element.postcode.contains(query) ||
                element.suburb.toLowerCase().contains(query))
            .take(5)
            .toList();
      }

      yield currState.copyWith(locationsResult: results);
    }
  }

  Stream<HomeState> _mapFilterCasesByPostcodeToState(
      FilterCasesByPostcode event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      var results = cases.where((myCase) {
        return _filterByStatus(myCase, currState.isShowAllCases) &&
            myCase.postcode == event.postcode;
      }).toList();
      yield currState.copyWith(
        casesResult: results,
        isEmptyActiveCases: !currState.isShowAllCases && results.isEmpty,
      );
    }
  }

  Stream<HomeState> _mapClearFilteredCasesToState(
      ClearFilteredCases event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState
          .copyWith(casesResult: <Case>[], locationsResult: <Location>[]);
    }
  }

  Stream<HomeState> _mapFilterCasesByExpiryToState(
      FilterCasesByExpiry event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final results = cases.where((myCase) {
        return _filterByStatus(myCase, event.isShowAllCases);
      }).toList();
      yield currState.copyWith(
        casesResult: results,
        isShowAllCases: event.isShowAllCases,
        isEmptyActiveCases: !event.isShowAllCases && results.isEmpty,
      );
    }
  }

  Stream<HomeState> _mapFilterCasesByDatesToState(
      FilterCasesByDates event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final results = cases.where((myCase) {
        return _filterByStatus(myCase, currState.isShowAllCases) &&
            myCase.dateTimes.first.start.isBefore(event.dates.end) &&
            myCase.dateTimes.last.end.isAfter(event.dates.start);
      }).toList();
      yield currState.copyWith(
        casesResult: results,
        isEmptyActiveCases: !currState.isShowAllCases && results.isEmpty,
      );
    }
  }

  Stream<HomeState> _mapEmptyActiveCasesHandledToState(
      EmptyActiveCasesHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(isEmptyActiveCases: false);
    }
  }

  Stream<HomeState> _mapSortCasesToState(SortCases event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.casesResult);
      if (event.sortBy == kAlphabetically) {
        cases.sort((a, b) => a.venue.compareTo(b.venue));
      } else if (event.sortBy == kMostRecent) {
        cases.sort(
            (a, b) => b.dateTimes.last.start.compareTo(a.dateTimes.last.start));
      }

      yield currState.copyWith(casesResult: cases, isSortCases: true);
    }
  }

  Stream<HomeState> _mapSortCasesHandledToState(SortCasesHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(isSortCases: false);
    }
  }

  bool _filterByStatus(Case myCase, bool isShowAllCases) {
    return (!isShowAllCases && !myCase.isExpired) || isShowAllCases;
  }
}

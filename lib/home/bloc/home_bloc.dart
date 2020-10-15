import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:nsw_covid_tracker/home/common/consts.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'home_bloc.g.dart';

part 'home_event.dart';
part 'home_state.dart';

typedef CasesComparator = int Function(Case a, Case b);

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo _homeRepo;

  HomeBloc(this._homeRepo) : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchAll) {
      yield* _mapFetchAllToState(event);
    } else if (event is Search) {
      yield* _mapSearchToState(event);
    } else if (event is FilterCasesByPostcode) {
      yield* _mapFilterCasesByPostcodeToState(event);
    } else if (event is SearchHandled) {
      yield* _mapSearchHandledToState(event);
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
    } else if (event is DisclaimerHandled) {
      yield* _mapDisclaimerHandledToState(event);
    } else if (event is ShowCase) {
      yield* _mapShowCaseToState(event);
    } else if (event is ShowCaseHandled) {
      yield* _mapShowCaseHandledToState(event);
    }
  }

  Stream<HomeState> _mapFetchAllToState(FetchAll event) async* {
    final currState = state;
    if (currState is HomeInitial) {
      try {
        final isShowDisclaimer = await _homeRepo.getIsShowDisclaimer();
        final locations = await _homeRepo.fetchLocations();
        final cases = await _homeRepo.fetchCases();
        final activeCases =
            cases.where((myCase) => (!myCase.isExpired)).toList();
        yield HomeSuccess(
          locations: locations,
          cases: cases,
          casesResult: activeCases,
          isEmptyActiveCases: activeCases.isEmpty,
          isShowDisclaimer: isShowDisclaimer,
        );
      } catch (_) {
        yield HomeFailure();
      }
    }
  }

  Stream<HomeState> _mapSearchToState(Search event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final query = event.query.toLowerCase();
      var locationsResult = <Location>[];
      var searchCases = <Case>[];

      if (query.isNotEmpty) {
        locationsResult = currState.locations
            .where((location) =>
                location.postcode.contains(query) ||
                location.suburb.toLowerCase().contains(query))
            .take(5)
            .toList();
        final cases = List<Case>.from(currState.cases)
          ..sort((a, b) => a.venue.compareTo(b.venue));
        searchCases = cases
            .where((myCase) => myCase.venue.toLowerCase().contains(query))
            .take(3)
            .toList();
      }

      yield currState.copyWith(
          locationsResult: locationsResult, searchCases: searchCases);
    }
  }

  Stream<HomeState> _mapFilterCasesByPostcodeToState(
      FilterCasesByPostcode event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final results = _filterCases(cases, currState.isShowAllCases,
          event.postcode, currState.filteredDates);
      yield currState.copyWith(
        casesResult: results,
        isEmptyActiveCases: !currState.isShowAllCases && results.isEmpty,
        filteredPostcode: event.postcode,
        isSearch: true,
      );
    }
  }

  Stream<HomeState> _mapSearchHandledToState(SearchHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(isSearch: false);
    }
  }

  Stream<HomeState> _mapClearFilteredCasesToState(
      ClearFilteredCases event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final results = cases.where((myCase) {
        return _filterByStatus(myCase, currState.isShowAllCases) &&
            _filterByDates(myCase, currState.filteredDates);
      }).toList();
      yield currState.copyWith(
        casesResult: results,
        locationsResult: <Location>[],
        searchCases: <Case>[],
      ).copyWithNull(filteredPostcode: true);
    }
  }

  Stream<HomeState> _mapFilterCasesByExpiryToState(
      FilterCasesByExpiry event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final results = _filterCases(cases, event.isShowAllCases,
          currState.filteredPostcode, currState.filteredDates);
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
      final results = _filterCases(cases, currState.isShowAllCases,
          currState.filteredPostcode, event.dates);
      yield currState.copyWith(
        casesResult: results,
        isEmptyActiveCases: !currState.isShowAllCases && results.isEmpty,
        filteredDates: event.dates,
      );
    }
  }

  Stream<HomeState> _mapEmptyActiveCasesHandledToState(
      EmptyActiveCasesHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(
          isEmptyActiveCases: false, isSearch: false, isShowDisclaimer: false);
    }
  }

  Stream<HomeState> _mapSortCasesToState(SortCases event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      final cases = List<Case>.from(currState.cases);
      final casesResult = List<Case>.from(currState.casesResult);
      CasesComparator comparator;

      if (event.sortBy == kAlphabetically) {
        comparator = (a, b) => a.venue.compareTo(b.venue);
      } else if (event.sortBy == kMostRecent) {
        comparator =
            (a, b) => b.dateTimes.last.end.compareTo(a.dateTimes.last.end);
      }

      cases.sort(comparator);
      casesResult.sort(comparator);
      yield currState.copyWith(
          cases: cases, casesResult: casesResult, isSortCases: true);
    }
  }

  Stream<HomeState> _mapSortCasesHandledToState(SortCasesHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(isSortCases: false);
    }
  }

  Stream<HomeState> _mapDisclaimerHandledToState(
      DisclaimerHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      await _homeRepo.setIsShowDisclaimer(false);
      yield currState.copyWith(
          isEmptyActiveCases: false, isShowDisclaimer: false);
    }
  }

  Stream<HomeState> _mapShowCaseToState(ShowCase event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWith(selectedCase: event.myCase);
    }
  }

  Stream<HomeState> _mapShowCaseHandledToState(ShowCaseHandled event) async* {
    final currState = state;
    if (currState is HomeSuccess) {
      yield currState.copyWithNull(selectedCase: true);
    }
  }

  List<Case> _filterCases(List<Case> cases, bool isShowAllCases,
      String postcode, DateTimeRange dates) {
    return cases.where((myCase) {
      return _filterByStatus(myCase, isShowAllCases) &&
          _filterByPostcode(myCase, postcode) &&
          _filterByDates(myCase, dates);
    }).toList();
  }

  bool _filterByStatus(Case myCase, bool isShowAllCases) {
    return (!isShowAllCases && !myCase.isExpired) || isShowAllCases;
  }

  bool _filterByPostcode(Case myCase, String postcode) {
    return postcode == null || myCase.postcode == postcode;
  }

  bool _filterByDates(Case myCase, DateTimeRange dates) {
    return dates == null ||
        (myCase.dateTimes.first.start.isBefore(dates.end) &&
            myCase.dateTimes.last.end.isAfter(dates.start));
  }
}

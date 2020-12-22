import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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

  HomeBloc(this._homeRepo) : super(HomeState());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchAll) {
      yield* _mapFetchAllToState(event);
    } else if (event is Search) {
      yield* _mapSearchToState(event);
    } else if (event is FilterCasesBySuburb) {
      yield* _mapFilterCasesBySuburbToState(event);
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
    } else if (event is EnableMap) {
      yield state.copyWith(isMapEnabled: true);
    } else if (event is DisableMap) {
      yield state.copyWith(isMapEnabled: false);
    }
  }

  Stream<HomeState> _mapFetchAllToState(FetchAll event) async* {
    if (state.status == HomeStatus.initial) {
      try {
        await _homeRepo.signInAnonymously();
        final updatedAt = await _homeRepo.fetchDataUpdatedAt();
        final suburbs = await _homeRepo.fetchSuburbs();
        final cases = await _homeRepo.fetchCases();
        final isShowDisclaimer = await _homeRepo.getIsShowDisclaimer();
        final activeCases =
            cases.where((myCase) => (!myCase.isExpired)).toList();

        yield state.copyWith(
          status: HomeStatus.success,
          updatedAt: updatedAt,
          suburbs: suburbs,
          cases: cases,
          casesResult: activeCases,
          isEmptyActiveCases: activeCases.isEmpty,
          isShowDisclaimer: isShowDisclaimer,
        );
      } catch (_) {
        yield state.copyWith(status: HomeStatus.failure);
      }
    }
  }

  Stream<HomeState> _mapSearchToState(Search event) async* {
    if (state.status == HomeStatus.success) {
      final query = event.query.toLowerCase();
      var suburbsResult = <Suburb>[];
      var searchCases = <Case>[];

      if (query.isNotEmpty) {
        suburbsResult = state.suburbs
            .where((suburb) {
              return suburb.postcode.contains(query) ||
                  suburb.name.toLowerCase().contains(query);
            })
            .take(5)
            .toList();
        final cases = List<Case>.from(state.cases)
          ..sort((a, b) => a.venue.compareTo(b.venue));
        searchCases = cases
            .where((myCase) => myCase.venue.toLowerCase().contains(query))
            .take(3)
            .toList();
      }

      yield state.copyWith(
        suburbsResult: suburbsResult,
        searchCases: searchCases,
      );
    }
  }

  Stream<HomeState> _mapFilterCasesBySuburbToState(
      FilterCasesBySuburb event) async* {
    if (state.status == HomeStatus.success) {
      final cases = List<Case>.from(state.cases);
      final results = _filterCases(
        cases,
        state.isShowAllCases,
        event.suburb,
        state.filteredDates,
      );

      HomeState newState;
      if (results.isEmpty) {
        newState = state.copyWithNull(targetLatLng: true);
      } else {
        newState = state.copyWith(targetLatLng: event.suburb.latLng);
      }

      yield newState.copyWith(
        casesResult: results,
        isEmptyActiveCases: !state.isShowAllCases && results.isEmpty,
        filteredSuburb: event.suburb,
      );
    }
  }

  Stream<HomeState> _mapSearchHandledToState(SearchHandled event) async* {
    if (state.status == HomeStatus.success) {
      yield state.copyWithNull(targetLatLng: true);
    }
  }

  Stream<HomeState> _mapClearFilteredCasesToState(
    ClearFilteredCases event,
  ) async* {
    if (state.status == HomeStatus.success) {
      final cases = List<Case>.from(state.cases);
      final results = cases.where((myCase) {
        return _filterByStatus(myCase, state.isShowAllCases) &&
            _filterByDates(myCase, state.filteredDates);
      }).toList();
      yield state.copyWith(
        casesResult: results,
        suburbsResult: <Suburb>[],
        searchCases: <Case>[],
      ).copyWithNull(filteredSuburb: true);
    }
  }

  Stream<HomeState> _mapFilterCasesByExpiryToState(
      FilterCasesByExpiry event) async* {
    if (state.status == HomeStatus.success) {
      final cases = List<Case>.from(state.cases);
      final results = _filterCases(cases, event.isShowAllCases,
          state.filteredSuburb, state.filteredDates);
      yield state.copyWith(
        casesResult: results,
        isShowAllCases: event.isShowAllCases,
        isEmptyActiveCases: !event.isShowAllCases && results.isEmpty,
      );
    }
  }

  Stream<HomeState> _mapFilterCasesByDatesToState(
      FilterCasesByDates event) async* {
    if (state.status == HomeStatus.success) {
      final cases = List<Case>.from(state.cases);
      final results = _filterCases(
          cases, state.isShowAllCases, state.filteredSuburb, event.dates);
      yield state.copyWith(
        casesResult: results,
        isEmptyActiveCases: !state.isShowAllCases && results.isEmpty,
        filteredDates: event.dates,
      );
    }
  }

  Stream<HomeState> _mapEmptyActiveCasesHandledToState(
      EmptyActiveCasesHandled event) async* {
    if (state.status == HomeStatus.success) {
      yield state
          .copyWith(isEmptyActiveCases: false, isShowDisclaimer: false)
          .copyWithNull(targetLatLng: true);
    }
  }

  Stream<HomeState> _mapSortCasesToState(SortCases event) async* {
    if (state.status == HomeStatus.success) {
      final cases = List<Case>.from(state.cases);
      final casesResult = List<Case>.from(state.casesResult);
      CasesComparator comparator;

      if (event.sortBy == kAlphabetically) {
        comparator = (a, b) => a.venue.compareTo(b.venue);
      } else if (event.sortBy == kMostRecent) {
        comparator =
            (a, b) => b.dateTimes.last.end.compareTo(a.dateTimes.last.end);
      }

      cases.sort(comparator);
      casesResult.sort(comparator);
      yield state.copyWith(
          cases: cases, casesResult: casesResult, isSortCases: true);
    }
  }

  Stream<HomeState> _mapSortCasesHandledToState(SortCasesHandled event) async* {
    if (state.status == HomeStatus.success) {
      yield state.copyWith(isSortCases: false);
    }
  }

  Stream<HomeState> _mapDisclaimerHandledToState(
      DisclaimerHandled event) async* {
    if (state.status == HomeStatus.success) {
      await _homeRepo.setIsShowDisclaimer(false);
      yield state.copyWith(isEmptyActiveCases: false, isShowDisclaimer: false);
    }
  }

  Stream<HomeState> _mapShowCaseToState(ShowCase event) async* {
    if (state.status == HomeStatus.success) {
      yield state.copyWith(selectedCase: event.myCase);
    }
  }

  Stream<HomeState> _mapShowCaseHandledToState(ShowCaseHandled event) async* {
    if (state.status == HomeStatus.success) {
      yield state.copyWithNull(selectedCase: true);
    }
  }

  List<Case> _filterCases(List<Case> cases, bool isShowAllCases, Suburb suburb,
      DateTimeRange dates) {
    return cases.where((myCase) {
      return _filterByStatus(myCase, isShowAllCases) &&
          _filterBySuburb(myCase, suburb) &&
          _filterByDates(myCase, dates);
    }).toList();
  }

  bool _filterByStatus(Case myCase, bool isShowAllCases) {
    return (!isShowAllCases && !myCase.isExpired) || isShowAllCases;
  }

  bool _filterBySuburb(Case myCase, Suburb suburb) {
    return suburb == null ||
        (myCase.postcode == suburb.postcode && myCase.suburb == suburb.name);
  }

  bool _filterByDates(Case myCase, DateTimeRange dates) {
    return dates == null ||
        (myCase.dateTimes.first.start.isBefore(dates.end) &&
            myCase.dateTimes.last.end.isAfter(dates.start));
  }
}

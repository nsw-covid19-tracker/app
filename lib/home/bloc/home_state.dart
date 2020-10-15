part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeFailure extends HomeState {}

@CopyWith(generateCopyWithNull: true)
class HomeSuccess extends HomeState {
  final List<Location> locations;
  final List<Case> cases;
  final List<Location> locationsResult;
  final List<Case> casesResult;
  final List<Case> searchCases;
  final bool isShowAllCases;
  final bool isEmptyActiveCases;
  final bool isSortCases;
  final LatLng targetLatLng;
  final String filteredPostcode;
  final DateTimeRange filteredDates;
  final bool isShowDisclaimer;
  final Case selectedCase;

  HomeSuccess({
    this.locations,
    this.cases,
    this.locationsResult = const <Location>[],
    this.casesResult = const <Case>[],
    this.searchCases = const <Case>[],
    this.isShowAllCases = false,
    this.isEmptyActiveCases = false,
    this.isSortCases = false,
    this.targetLatLng,
    this.filteredPostcode,
    this.filteredDates,
    this.isShowDisclaimer = true,
    this.selectedCase,
  });

  @override
  List<Object> get props {
    return [
      locations,
      cases,
      locationsResult,
      casesResult,
      searchCases,
      isShowAllCases,
      isEmptyActiveCases,
      isSortCases,
      filteredPostcode,
      filteredDates,
      isShowDisclaimer,
      selectedCase,
    ];
  }

  @override
  String toString() {
    return 'HomeSuccess: { locations: ${locations?.length}, '
        'cases: ${cases?.length}, locationsResult: ${locationsResult?.length}, '
        'casesResult: ${casesResult?.length}, '
        'searchCases: ${searchCases?.length}, '
        'isShowAllCases: $isShowAllCases, targetLatLng: $targetLatLng, '
        'isEmptyActiveCases: $isEmptyActiveCases, isSortCases: $isSortCases, '
        'filteredPostcode: $filteredPostcode, filteredDates: $filteredDates, '
        'isShowDisclaimer: $isShowDisclaimer, '
        'selectedCase: ${selectedCase != null} }';
  }
}

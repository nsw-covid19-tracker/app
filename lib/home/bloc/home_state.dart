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
  final bool isShowAllCases;
  final bool isEmptyActiveCases;
  final bool isSortCases;
  final bool isSearch;
  final String filteredPostcode;
  final DateTimeRange filteredDates;

  HomeSuccess({
    this.locations,
    this.cases,
    this.locationsResult = const <Location>[],
    this.casesResult = const <Case>[],
    this.isShowAllCases = false,
    this.isEmptyActiveCases = false,
    this.isSortCases = false,
    this.isSearch = false,
    this.filteredPostcode,
    this.filteredDates,
  });

  @override
  List<Object> get props {
    return [
      locations,
      cases,
      locationsResult,
      casesResult,
      isShowAllCases,
      isEmptyActiveCases,
      isSortCases,
      filteredPostcode,
      filteredDates,
    ];
  }

  @override
  String toString() {
    return 'HomeSuccess: { locations: ${locations?.length}, '
        'cases: ${cases?.length}, locationsResult: ${locationsResult?.length}, '
        'casesResult: ${casesResult?.length}, '
        'isShowAllCases: $isShowAllCases, isSearch: $isSearch, '
        'isEmptyActiveCases: $isEmptyActiveCases, isSortCases: $isSortCases, '
        'filteredPostcode: $filteredPostcode, filteredDates: $filteredDates }';
  }
}

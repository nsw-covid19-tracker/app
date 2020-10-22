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
  final DateTime updatedAt;
  final List<Suburb> suburbs;
  final List<Case> cases;
  final List<Suburb> suburbsResult;
  final List<Case> casesResult;
  final List<Case> searchCases;
  final bool isShowAllCases;
  final bool isEmptyActiveCases;
  final bool isSortCases;
  final LatLng targetLatLng;
  final Suburb filteredSuburb;
  final DateTimeRange filteredDates;
  final bool isShowDisclaimer;
  final Case selectedCase;

  HomeSuccess({
    this.updatedAt,
    this.suburbs,
    this.cases,
    this.suburbsResult = const <Suburb>[],
    this.casesResult = const <Case>[],
    this.searchCases = const <Case>[],
    this.isShowAllCases = false,
    this.isEmptyActiveCases = false,
    this.isSortCases = false,
    this.targetLatLng,
    this.filteredSuburb,
    this.filteredDates,
    this.isShowDisclaimer = true,
    this.selectedCase,
  });

  @override
  List<Object> get props {
    return [
      updatedAt,
      suburbs,
      cases,
      suburbsResult,
      casesResult,
      searchCases,
      isShowAllCases,
      isEmptyActiveCases,
      isSortCases,
      filteredSuburb,
      filteredDates,
      isShowDisclaimer,
      selectedCase,
    ];
  }

  @override
  String toString() {
    return 'HomeSuccess: { updatedAt: $updatedAt, suburbs: ${suburbs?.length}, '
        'cases: ${cases?.length}, suburbsResult: ${suburbsResult?.length}, '
        'casesResult: ${casesResult?.length}, '
        'searchCases: ${searchCases?.length}, '
        'isShowAllCases: $isShowAllCases, targetLatLng: $targetLatLng, '
        'isEmptyActiveCases: $isEmptyActiveCases, isSortCases: $isSortCases, '
        'filteredSuburb: $filteredSuburb, filteredDates: $filteredDates, '
        'isShowDisclaimer: $isShowDisclaimer, '
        'selectedCase: ${selectedCase != null} }';
  }

  String get formattedUpdatedAt {
    final dateFormat = DateFormat('d MMM, yyyy');

    return updatedAt != null ? dateFormat.format(updatedAt) : 'Unknown';
  }
}

part of 'home_bloc.dart';

enum HomeStatus { initial, success, failure }

@CopyWith(generateCopyWithNull: true)
class HomeState extends Equatable {
  final HomeStatus status;
  final DateTime updatedAt;

  final List<Suburb> suburbs;
  final List<Suburb> suburbsResult;

  final List<Case> cases;
  final List<Case> casesResult;
  final List<Case> searchCases;

  final bool isShowAllCases;
  final bool isEmptyActiveCases;
  final bool isSortCases;
  final bool isShowDisclaimer;
  final bool isMapEnabled;

  final LatLng targetLatLng;
  final Suburb filteredSuburb;
  final DateTimeRange filteredDates;
  final Case selectedCase;

  HomeState({
    this.status = HomeStatus.initial,
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
    this.isMapEnabled = true,
  });

  @override
  List<Object> get props {
    return [
      status,
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
      isMapEnabled,
    ];
  }

  @override
  String toString() {
    return 'HomeSuccess: { status: $status, updatedAt: $updatedAt, '
        'suburbs: ${suburbs?.length}, cases: ${cases?.length}, '
        'suburbsResult: ${suburbsResult?.length}, '
        'casesResult: ${casesResult?.length}, '
        'searchCases: ${searchCases?.length}, '
        'isShowAllCases: $isShowAllCases, targetLatLng: $targetLatLng, '
        'isEmptyActiveCases: $isEmptyActiveCases, isSortCases: $isSortCases, '
        'filteredSuburb: $filteredSuburb, filteredDates: $filteredDates, '
        'isShowDisclaimer: $isShowDisclaimer, '
        'selectedCase: ${selectedCase != null}, isMapEnabled: $isMapEnabled }';
  }

  String get formattedUpdatedAt {
    return updatedAt != null
        ? DateFormat('d MMM, yyyy').format(updatedAt)
        : 'Unknown';
  }

  bool get isMapEnabledFinal => !kIsWeb || (kIsWeb && isMapEnabled);
}

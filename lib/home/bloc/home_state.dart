part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeFailure extends HomeState {}

@CopyWith()
class HomeSuccess extends HomeState {
  final List<Location> locations;
  final List<Case> cases;
  final List<Location> locationsResult;
  final List<Case> casesResult;
  final bool isShowAllCases;

  HomeSuccess({
    this.locations,
    this.cases,
    this.locationsResult = const <Location>[],
    this.casesResult = const <Case>[],
    this.isShowAllCases = false,
  });

  @override
  List<Object> get props {
    return [locations, cases, locationsResult, casesResult, isShowAllCases];
  }

  @override
  String toString() {
    return 'HomeSuccess: { locations: ${locations?.length}, '
        'cases: ${cases?.length}, locationsResult: ${locationsResult?.length}, '
        'casesResult: ${casesResult?.length}, '
        'isShowAllCases: $isShowAllCases }';
  }
}

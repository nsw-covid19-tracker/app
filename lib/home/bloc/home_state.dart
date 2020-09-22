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

  HomeSuccess(
      {this.locations, this.cases, this.locationsResult, this.casesResult});

  @override
  List<Object> get props => [locations, cases, locationsResult, casesResult];
}

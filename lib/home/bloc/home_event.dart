part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchAll extends HomeEvent {}

class SearchLocations extends HomeEvent {
  final String query;

  SearchLocations(this.query);

  @override
  List<Object> get props => [query];
}

class FilterCasesByPostcode extends HomeEvent {
  final String postcode;

  FilterCasesByPostcode(this.postcode);

  @override
  List<Object> get props => [postcode];
}

class ClearFilteredCases extends HomeEvent {}

class FilterCasesByExpiry extends HomeEvent {
  final bool isShowNotExpiredOnly;

  FilterCasesByExpiry(this.isShowNotExpiredOnly);

  @override
  List<Object> get props => [isShowNotExpiredOnly];
}

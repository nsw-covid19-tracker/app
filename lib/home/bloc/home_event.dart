part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchAll extends HomeEvent {}

class Search extends HomeEvent {
  final String query;

  Search(this.query);

  @override
  List<Object> get props => [query];
}

class FilterCasesBySuburb extends HomeEvent {
  final Suburb suburb;

  FilterCasesBySuburb(this.suburb);

  @override
  List<Object> get props => [suburb];
}

class SearchHandled extends HomeEvent {}

class ClearFilteredCases extends HomeEvent {}

class FilterCasesByExpiry extends HomeEvent {
  final bool isShowAllCases;

  FilterCasesByExpiry(this.isShowAllCases);

  @override
  List<Object> get props => [isShowAllCases];
}

class FilterCasesByDates extends HomeEvent {
  final DateTimeRange dates;

  FilterCasesByDates(this.dates);

  @override
  List<Object> get props => [dates];
}

class EmptyActiveCasesHandled extends HomeEvent {}

class SortCases extends HomeEvent {
  final String sortBy;

  SortCases(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}

class SortCasesHandled extends HomeEvent {}

class DisclaimerHandled extends HomeEvent {}

class ShowCase extends HomeEvent {
  final Case myCase;

  ShowCase(this.myCase);

  @override
  List<Object> get props => [myCase];
}

class ShowCaseHandled extends HomeEvent {}

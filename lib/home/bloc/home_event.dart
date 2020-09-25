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

import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBar extends StatefulWidget {
  final Function onSearchBarTap;

  const SearchBar({Key key, this.onSearchBarTap}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _controller = FloatingSearchBarController();
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: _controller,
      hint: 'Postcode or Suburb',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        if (query.isNotEmpty) {
          _homeBloc.add(Search(query));
        } else {
          _homeBloc.add(ClearFilteredCases());
        }
      },
      onFocusChanged: (isFocused) {
        if (isFocused) {
          widget.onSearchBarTap?.call();
        }
      },
      clearQueryOnClose: false,
      transition: CircularFloatingSearchBarTransition(),
      automaticallyImplyDrawerHamburger: false,
      automaticallyImplyBackButton: false,
      actions: [
        FloatingSearchBarAction.searchToClear(showIfClosed: true),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return previous is HomeSuccess &&
                    current is HomeSuccess &&
                    (previous.suburbsResult != current.suburbsResult ||
                        previous.searchCases != current.searchCases);
              },
              builder: (context, state) {
                if (state is HomeSuccess &&
                    (state.suburbsResult.isNotEmpty ||
                        state.searchCases.isNotEmpty)) {
                  return _SearchResults(
                    controller: _controller,
                    suburbs: state.suburbsResult,
                    cases: state.searchCases,
                  );
                }

                return ListTile(title: Text('No results found'));
              },
            ),
          ),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final FloatingSearchBarController controller;
  final List<Suburb> suburbs;
  final List<Case> cases;

  const _SearchResults({
    Key key,
    @required this.controller,
    @required this.suburbs,
    @required this.cases,
  })  : assert(controller != null),
        assert(suburbs != null),
        assert(cases != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        if (suburbs.isNotEmpty)
          Text(
            'Suburbs',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: 1),
          ),
        ...suburbs.map((suburb) {
          return ListTile(
            title: Text(suburb.displayName),
            onTap: () {
              controller.query = suburb.displayName;
              controller.close();
              context.read<HomeBloc>().add(FilterCasesBySuburb(suburb));
            },
          );
        }),
        if (cases.isNotEmpty)
          Text(
            'Case Locations',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: 1),
          ),
        ...cases.map((myCase) {
          return ListTile(
            title: Text(myCase.venue),
            onTap: () {
              controller.query = myCase.venue;
              controller.close();
              context.read<HomeBloc>().add(ShowCase(myCase));
            },
          );
        }),
      ],
    );
  }
}

import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBar extends StatefulWidget {
  final Function onSearchBarTap;

  const SearchBar({
    Key key,
    @required this.onSearchBarTap,
  })  : assert(onSearchBarTap != null),
        super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = FloatingSearchBarController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: controller,
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
          context.bloc<HomeBloc>().add(Search(query));
        } else {
          context.bloc<HomeBloc>().add(ClearFilteredCases());
        }
      },
      onFocusChanged: (isFocused) {
        if (isFocused) {
          widget.onSearchBarTap();
        }
      },
      clearQueryOnClose: false,
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      showDrawerHamburger: false,
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
              builder: (context, state) {
                if (state is HomeSuccess &&
                    (state.locationsResult.isNotEmpty ||
                        state.searchCases.isNotEmpty)) {
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (state.locationsResult.isNotEmpty)
                        Text(
                          'Suburbs',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(fontWeightDelta: 1),
                        ),
                      ...state.locationsResult.map((location) {
                        return ListTile(
                          title: Text(location.name),
                          onTap: () {
                            controller.query = location.suburb;
                            controller.close();
                            context
                                .bloc<HomeBloc>()
                                .add(FilterCasesByPostcode(location.postcode));
                          },
                        );
                      }),
                      if (state.searchCases.isNotEmpty)
                        Text(
                          'Case Locations',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(fontWeightDelta: 1),
                        ),
                      ...state.searchCases.map((myCase) {
                        return ListTile(
                          title: Text(myCase.venue),
                          onTap: () {
                            controller.query = myCase.venue;
                            controller.close();
                            context.bloc<HomeBloc>().add(ShowCase(myCase));
                          },
                        );
                      }),
                    ],
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

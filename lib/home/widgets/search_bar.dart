import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBar extends StatefulWidget {
  final List<Location> locations;
  final Function onSearchResultTap;
  final Function onSearchBarTap;

  const SearchBar({
    Key key,
    @required this.locations,
    @required this.onSearchResultTap,
    @required this.onSearchBarTap,
  })  : assert(locations != null),
        assert(onSearchResultTap != null),
        assert(onSearchBarTap != null),
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
          context.bloc<HomeBloc>().add(SearchLocations(query));
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
      actions: [
        FloatingSearchBarAction.searchToClear(showIfClosed: true),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: widget.locations.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.locations.map((location) {
                      return ListTile(
                        title: Text(location.suburb),
                        onTap: () {
                          controller.query = location.suburb;
                          controller.close();
                          widget.onSearchResultTap();
                          context
                              .bloc<HomeBloc>()
                              .add(FilterCases(location.postcode));
                        },
                      );
                    }).toList(),
                  )
                : ListTile(title: Text('No results found')),
          ),
        );
      },
    );
  }
}

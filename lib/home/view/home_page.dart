import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _panelController = PanelController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.bloc<HomeBloc>()..add(FetchAll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          var cases = <Case>[];
          var locations = <Location>[];

          if (state is HomeSuccess) {
            locations = state.locationsResult;
            if (state.casesResult.isEmpty) {
              cases = state.cases;
            } else {
              cases = state.casesResult;
            }
          }

          return SlidingUpPanel(
            controller: _panelController,
            minHeight: 80,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            collapsed: cases.isEmpty
                ? LoadingPanel()
                : CollapsedPanel(controller: _panelController),
            panelBuilder: (sc) => Panel(
              panelSc: sc,
              panelController: _panelController,
              cases: cases,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Map(
                  scrollController: _scrollController,
                  panelController: _panelController,
                  cases: cases,
                ),
                SearchBar(
                  locations: locations,
                  onSearchBarTap: () => _panelController.close(),
                  onSearchResultTap: () => _panelController.open(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

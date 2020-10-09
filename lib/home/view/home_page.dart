import 'package:awesome_dialog/awesome_dialog.dart';
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
  final _panelMinHeight = 80.0;
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.bloc<HomeBloc>()..add(FetchAll());
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
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccess && state.isEmptyActiveCases) {
            _showNoActiveCasesDialog();
            _homeBloc.add(EmptyActiveCasesHandled());
          }
        },
        builder: (context, state) {
          var isLoading = true;
          var cases = <Case>[];
          var locations = <Location>[];

          if (state is HomeSuccess) {
            isLoading = false;
            locations = state.locationsResult;
            cases = state.casesResult;
          }

          return SlidingUpPanel(
            controller: _panelController,
            minHeight: _panelMinHeight,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            collapsed: isLoading
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
                MapWidget(
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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _panelMinHeight),
        child: FilterButton(),
      ),
    );
  }

  void _showNoActiveCasesDialog() {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      title: 'No active cases found',
      desc: 'Keep maintaining social distancing and '
          'wear a mask when physical distancing is not possible',
      btnOkOnPress: () {},
      btnOkText: 'Close',
    )..show();
  }
}

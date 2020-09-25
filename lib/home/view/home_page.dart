import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _panelController = PanelController();
  final _scrollController = ScrollController();

  HomeBloc _homeBloc;
  bool _isLoading = true;
  Set<Marker> _markers;
  var _cases = <Case>[];

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
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccess) {
            setState(() {
              _isLoading = false;
              if (state.cases != null && _markers == null) {
                _cases = state.cases;
                _markers = _mapCasesToMarkers(state.cases);
              }
            });
          }
        },
        child: SlidingUpPanel(
          controller: _panelController,
          minHeight: 80,
          collapsed: _isLoading
              ? LoadingPanel()
              : CollapsedPanel(controller: _panelController),
          panelBuilder: (sc) => Panel(
            scrollController: sc,
            panelController: _panelController,
            cases: _cases,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Map(panelController: _panelController, markers: _markers),
              SearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Set<Marker> _mapCasesToMarkers(List<Case> cases) {
    final markers = <Marker>{};
    for (var myCase in cases) {
      markers.add(Marker(
        markerId: MarkerId(myCase.location),
        position: myCase.latLng,
        onTap: () => CaseDialog.show(context, _scrollController, myCase),
      ));
    }

    return markers;
  }
}

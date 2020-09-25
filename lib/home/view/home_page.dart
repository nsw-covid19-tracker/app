import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/common/consts.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
        onTap: () => _showCaseInfo(myCase),
      ));
    }

    return markers;
  }

  void _showCaseInfo(Case myCase) {
    final height = MediaQuery.of(context).size.height * 0.3;
    final expiredText = myCase.isExpired ? ' (Expired)' : '';
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: myCase.isExpired ? DialogType.INFO : DialogType.WARNING,
      body: Container(
        height: height,
        padding: kLayoutPadding,
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView(
            controller: _scrollController,
            children: [
              Text(
                '${myCase.location}$expiredText',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .apply(fontWeightDelta: 1),
              ),
              WidgetPaddingSm(),
              Text('Dates', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(myCase.dates),
              WidgetPaddingSm(),
              RichText(
                text: TextSpan(
                  text: 'Suggested Action ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '(If you visited this location at the times above)',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Text(myCase.action),
              WidgetPaddingSm(),
            ],
          ),
        ),
      ),
      btnOkOnPress: () {},
      btnOkText: 'Close',
    )..show();
  }
}

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
              ? _LoadingPanel()
              : _CollapsedPanel(controller: _panelController),
          panelBuilder: (sc) => _Panel(
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
                myCase.location,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .apply(fontWeightDelta: 1),
              ),
              WidgetPadding(),
              Text(myCase.dates),
            ],
          ),
        ),
      ),
      btnOkOnPress: () {},
      btnOkText: 'Close',
    )..show();
  }
}

class _LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Fetching locations'),
      ],
    );
  }
}

class _CollapsedPanel extends StatelessWidget {
  final PanelController controller;

  const _CollapsedPanel({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.open(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _SlidingBar(),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list),
                  SizedBox(width: 8),
                  Text(
                    'Show List',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  final List<Case> cases;

  const _Panel({
    Key key,
    @required this.cases,
    @required this.panelController,
    this.scrollController,
  })  : assert(cases != null),
        assert(panelController != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => panelController.close(),
          child: _SlidingBar(),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: cases.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(cases[index].location),
              subtitle: Text(cases[index].dates),
            ),
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlidingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

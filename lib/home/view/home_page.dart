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
  final _controller = PanelController();
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
          controller: _controller,
          minHeight: 80,
          collapsed: _isLoading
              ? _LoadingPanel()
              : _CollapsedPanel(controller: _controller),
          panelBuilder: (sc) => _Panel(controller: sc, cases: _cases),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Map(panelController: _controller, markers: _markers),
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
      ));
    }

    return markers;
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
  final ScrollController controller;
  final List<Case> cases;

  const _Panel({Key key, @required this.cases, this.controller})
      : assert(cases != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SlidingBar(),
        SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            controller: controller,
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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:nsw_covid_tracker/home/widgets/case_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapWidget extends StatefulWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  final List<Case> cases;

  MapWidget({
    Key key,
    this.cases,
    @required this.scrollController,
    @required this.panelController,
  })  : assert(scrollController != null),
        assert(panelController != null),
        super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final _completer = Completer<GoogleMapController>();

  final _kGooglePlex = CameraPosition(
    target: LatLng(-33.918200, 151.035000),
    zoom: 9,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is HomeSuccess && state.targetLatLng != null) {
          final controller = await _completer.future;
          await controller.animateCamera(
              CameraUpdate.newLatLngZoom(state.targetLatLng, 15));
          context.bloc<HomeBloc>().add(SearchHandled());
        }
      },
      builder: (context, state) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _completer.complete(controller);
          },
          markers: widget.cases != null
              ? _mapCasesToMarkers(context, widget.cases)
              : null,
          onTap: (_) => widget.panelController.close(),
        );
      },
    );
  }

  Set<Marker> _mapCasesToMarkers(BuildContext context, List<Case> cases) {
    final markers = <Marker>{};
    for (var myCase in cases) {
      markers.add(Marker(
        markerId: MarkerId(myCase.venue),
        position: myCase.latLng,
        onTap: () => CaseDialog.show(context, widget.scrollController, myCase),
      ));
    }

    return markers;
  }
}

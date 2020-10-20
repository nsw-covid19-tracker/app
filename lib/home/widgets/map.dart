import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:nsw_covid_tracker/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Function onMapTap;

  MapWidget({Key key, @required this.scrollController, this.onMapTap})
      : assert(scrollController != null),
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
      listenWhen: (previous, current) {
        return previous is HomeSuccess &&
            current is HomeSuccess &&
            previous.targetLatLng != current.targetLatLng;
      },
      listener: (context, state) async {
        if (state is HomeSuccess && state.targetLatLng != null) {
          final controller = await _completer.future;
          await controller.animateCamera(
              CameraUpdate.newLatLngZoom(state.targetLatLng, 15));
          context.bloc<HomeBloc>().add(SearchHandled());
        }
      },
      buildWhen: (previous, current) {
        return previous is HomeInitial ||
            (previous is HomeSuccess &&
                current is HomeSuccess &&
                previous.casesResult != current.casesResult);
      },
      builder: (context, state) {
        var cases = <Case>[];
        if (state is HomeSuccess) cases = state.casesResult;

        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _completer.complete(controller);
          },
          markers: cases.isNotEmpty ? _mapCasesToMarkers(context, cases) : null,
          onTap: (_) => widget.onMapTap?.call(),
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

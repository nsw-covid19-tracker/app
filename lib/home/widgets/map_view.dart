import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:nsw_covid_tracker/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final ScrollController scrollController;
  final Function onMapTap;

  MapView({
    Key key,
    @required this.scrollController,
    this.onMapTap,
  })  : assert(scrollController != null),
        super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _completer = Completer<GoogleMapController>();
  final _kGooglePlex = CameraPosition(
    target: LatLng(-33.918200, 151.035000),
    zoom: 9,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        return previous.targetLatLng != current.targetLatLng;
      },
      listener: (context, state) async {
        if (state.targetLatLng != null) {
          final controller = await _completer.future;
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(state.targetLatLng, 15),
          );
          context.read<HomeBloc>().add(SearchHandled());
        }
      },
      buildWhen: (previous, current) {
        return previous.casesResult != current.casesResult ||
            previous.isMapEnabled != current.isMapEnabled;
      },
      builder: (context, state) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            if (!_completer.isCompleted) _completer.complete(controller);
          },
          markers: _mapCasesToMarkers(context, state.casesResult),
          onTap: (_) => widget.onMapTap?.call(),
          scrollGesturesEnabled: !kIsWeb || (kIsWeb && state.isMapEnabled),
        );
      },
    );
  }

  Set<Marker> _mapCasesToMarkers(BuildContext context, List<Case> cases) {
    return cases.map((myCase) {
      return Marker(
        markerId: MarkerId(myCase.venue),
        position: myCase.latLng,
        onTap: () => CaseDialog.show(context, widget.scrollController, myCase),
      );
    }).toSet();
  }
}

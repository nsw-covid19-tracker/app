import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Map extends StatelessWidget {
  final PanelController panelController;
  final Set<Marker> markers;

  Map({Key key, this.markers, @required this.panelController})
      : assert(panelController != null),
        super(key: key);

  final _controller = Completer<GoogleMapController>();
  final _kGooglePlex = CameraPosition(
    target: LatLng(-33.868800, 151.209300),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
      onTap: (_) => panelController.close(),
    );
  }
}

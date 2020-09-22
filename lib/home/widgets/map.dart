import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Map extends StatefulWidget {
  final PanelController panelController;
  final Set<Marker> markers;

  const Map({Key key, this.markers, @required this.panelController})
      : assert(panelController != null),
        super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
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
      markers: widget.markers,
      onTap: (_) => widget.panelController.close(),
    );
  }
}

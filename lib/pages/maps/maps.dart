import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sibos/pages/maps/maps_view.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  Completer<GoogleMapController> conMap = Completer();

  TextEditingController conSearch = TextEditingController();

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(-7.527317, 110.667700),
    zoom: 17,
  );

  @override
  void dispose() {
    conSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MapsView(this);
}

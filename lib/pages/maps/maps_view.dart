import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/pages/maps/maps.dart';
import 'package:sibos/widgets/search_bar.dart';

class MapsView extends StatelessWidget {
  final MapsPageState state;
  const MapsView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox(
            height: Helper.getScreenHeight(context),
            child: GoogleMap(
              initialCameraPosition: state.cameraPosition,
              onMapCreated: (controller) {
                if (!state.conMap.isCompleted) {
                  state.conMap.complete(controller);
                }
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: SearchBar(
                      controller: state.conSearch,
                      hintText: "Cari bengkel",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

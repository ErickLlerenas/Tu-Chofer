import 'package:chofer/components/footer.dart';
import 'package:chofer/components/to-input.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {
  final scaffoldKey;
  Map(this.scaffoldKey);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return appState.initialPosition == null
        ? Container(
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(children: <Widget>[
            GoogleMap(
              buildingsEnabled: true,
              indoorViewEnabled: true,
              initialCameraPosition:
                  CameraPosition(target: appState.initialPosition, zoom: 15),
              onMapCreated: appState.onMapCreated,
              myLocationEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              polylines: appState.polyLines,
              markers: appState.markers,
            ),
            appState.destinationController.text.isEmpty ? ToInput() : Footer(),
            Positioned(
              left: 8,
              top: 25,
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => widget.scaffoldKey.currentState.openDrawer(),
              ),
            ),
          ]);
  }
}

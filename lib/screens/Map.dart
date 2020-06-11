import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/components/where-to-go-button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return appState.initialPosition == null ? Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ): Stack(
      children: <Widget>[
        GoogleMap(
            initialCameraPosition:
                CameraPosition(target: appState.initialPosition, zoom: 15),
            onMapCreated: appState.onMapCreated,
            myLocationEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            polylines: appState.polyLines,
            markers: appState.markers,
        ),
        WhereToGoButton()
      ],
    );
  }

}

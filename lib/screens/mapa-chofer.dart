import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';

class MapaChofer extends StatefulWidget{
  @override
  _MapaChoferState createState() => _MapaChoferState();
}

class _MapaChoferState extends State<MapaChofer> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body:Stack(children: <Widget>[
            GoogleMap(
              trafficEnabled: true,
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
            Positioned(
              left: 10,
              top: 20,
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {},
              ),
            ),
          ])
    );
  }
}
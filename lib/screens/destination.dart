import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:search_map_place/search_map_place.dart';

class Destination extends StatefulWidget {
  @override
  _DestinationState createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        title: Row(
          children: <Widget>[Text('Destino')],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
                child: SearchMapPlaceWidget(
                  iconColor: Colors.red[400],
              apiKey: "AIzaSyB6TIHbzMpZYQs8VwYMuUZaMuk4VaKudeY",
              placeholder: "${appState.destinationController.text}",
              language: 'es',
              location: appState.initialPosition,
              radius: 30000,
              onSelected: (Place place) async {
                final geolocation = await place.geolocation;
                appState.changeDestination(geolocation.coordinates,place.description);
                appState.destinationController.text = place.description;
                final GoogleMapController controller = appState.mapController;
                controller.animateCamera(
                    CameraUpdate.newLatLng(geolocation.coordinates));
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
                Navigator.pop(context);
              },
            )),
          ],
        ))
    );
  }
}

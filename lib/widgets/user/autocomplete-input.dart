import 'package:chofer/widgets/user/recomended-search.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class AutoCompleteInput extends StatefulWidget {
  @override
  _AutoCompleteInputState createState() => _AutoCompleteInputState();
}

class _AutoCompleteInputState extends State<AutoCompleteInput> {
  GoogleMapController controller;
  @override
  void dispose() {
    super.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    String firstName = appState.name.split(' ')[0];
    return Container(
        margin: EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Column(
          children: [
            SingleChildScrollView(
                child: SearchMapPlaceWidget(
              darkMode: false,
              iconColor: Colors.grey[700],
              apiKey: "AIzaSyB6TIHbzMpZYQs8VwYMuUZaMuk4VaKudeY",
              placeholder: "Hola $firstName, ¿A dónde quieres ir?",
              language: 'es',
              location: appState.initialPosition,
              radius: 20000,
              onSelected: (Place place) async {
                final geolocation = await place.geolocation;
                appState.sendRequest(place.description);
                appState.destinationController.text = place.description;
                controller = appState.mapController;
                controller.animateCamera(
                    CameraUpdate.newLatLng(geolocation.coordinates));
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
              },
            )),
            RecomendedSearch(phone: appState.phone)
          ],
        ));
  }
}

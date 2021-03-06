import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:search_map_place/search_map_place.dart';

class ChangeOrigin extends StatefulWidget {
  @override
  _ChangeOriginState createState() => _ChangeOriginState();
}

class _ChangeOriginState extends State<ChangeOrigin> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        appBar:
            AppBar(backgroundColor: Colors.blue[400], title: Text('Origen')),
        body: Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SingleChildScrollView(
                    child: SearchMapPlaceWidget(
                  iconColor: Colors.blue[400],
                  apiKey: "AIzaSyB6TIHbzMpZYQs8VwYMuUZaMuk4VaKudeY",
                  placeholder: "${appState.locationController.text}",
                  language: 'es',
                  location: appState.initialPosition,
                  radius: 30000,
                  onSelected: (Place place) async {
                    final geolocation = await place.geolocation;
                    appState.locationController.text = place.description;
                    Navigator.maybePop(context);
                    appState.changeOrigin(geolocation.coordinates);
                    appState.mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: geolocation.coordinates, zoom: 14),
                      ),
                    );
                  },
                )),
              ],
            )));
  }
}

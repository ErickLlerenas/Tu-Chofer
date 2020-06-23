import 'dart:async';
import 'dart:typed_data';
import 'package:chofer/components/chofer-Footer.dart';
import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MapaChofer extends StatefulWidget {
  @override
  _MapaChoferState createState() => _MapaChoferState();
}

class _MapaChoferState extends State<MapaChofer> {
  bool isActive = false;
  Location _location = Location();
  StreamSubscription locationSubscription;
  Marker _marker;
  GoogleMapController _mapController;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car.png");
    return byteData.buffer.asUint8List();
  }

  void updateCarMarker(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    setState(() {
      _marker = Marker(
          markerId: MarkerId(Uuid().v1()),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
    });
  }

  void clearCar() {
    _marker = null;
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _location.getLocation();
      updateCarMarker(location, imageData);

      if (locationSubscription != null) {
        locationSubscription.cancel();
      }

      locationSubscription = _location.onLocationChanged.listen((newLocalData) {
        if (_mapController != null) {
          if (isActive) {
            _mapController.animateCamera(CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: 0,
                    tilt: 0,
                    zoom: 16.5,
                    target: LatLng(
                        newLocalData.latitude, newLocalData.longitude))));
            updateCarMarker(newLocalData, imageData);
          }
        }
      });
    } catch (e) {}
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.local_taxi),
          backgroundColor: isActive ? Colors.deepPurpleAccent : Colors.black,
          onPressed: () {
            setState(() {
              isActive = !isActive;
              print(isActive);

              if (isActive)
                getCurrentLocation();
              else
                clearCar();
            });
          },
        ),
        key: _scaffoldKey,
        drawer: CustomDrawer(),
        body: StreamBuilder(
            stream: Firestore.instance.collection('Users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Container();

              if (isActive) {
                if (snapshot.data.documents[0]['isAskingService']) {
                  // WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog(context,snapshot.data.documents[0]['originName'],snapshot.data.documents[0]['destinationName'],snapshot.data.documents[0]['phone']));
                }
              }
              return Stack(children: <Widget>[
                GoogleMap(
                  compassEnabled: false,
                  trafficEnabled: true,
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: appState.initialPosition, zoom: 15),
                  onMapCreated: onMapCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  polylines: appState.polyLines,
                  markers: Set.of((_marker != null ? [_marker] : [])),
                ),
                isActive && snapshot.data.documents[0]['isAskingService']
                    ? ChoferFooter(
                        origin: snapshot.data.documents[0]['originName'],
                        destination: snapshot.data.documents[0]
                            ['destinationName'],
                        price: snapshot.data.documents[0]['price'],
                        distance: snapshot.data.documents[0]['distance'],
                        duration: snapshot.data.documents[0]['duration'],
                        phone: snapshot.data.documents[0]['phone'])
                    : Container(),
                Positioned(
                  left: 8,
                  top: 25,
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                ),
              ]);
            }));
  }
}

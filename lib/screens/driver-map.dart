import 'dart:async';
import 'dart:typed_data';
import 'package:chofer/components/driver-footer.dart';
import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/requests/google-maps-requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMapState createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  bool isActive = false;
  bool driverIsOnDriverScreen = true;
  Location _location = Location();
  StreamSubscription locationSubscription;
  Marker _marker;
  GoogleMapController _mapController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  Future getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car.png");
    return byteData.buffer.asUint8List();
  }

  void updateCarMarker(
      LocationData newLocalData, Uint8List imageData, appState) async {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    await Firestore.instance
        .collection('Drivers')
        .document(appState.phone)
        .updateData({
      'currentLocation':
          new GeoPoint(newLocalData.latitude, newLocalData.longitude),
      'currentLocationHeading': newLocalData.heading
    });
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

  void getCurrentLocation(appState) async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _location.getLocation();
      updateCarMarker(location, imageData, appState);

      if (locationSubscription != null) {
        locationSubscription.cancel();
      }

      locationSubscription = _location.onLocationChanged.listen((newLocalData) {
        if (_mapController != null) {
          if (isActive) {
            if (driverIsOnDriverScreen) {
              _mapController.animateCamera(CameraUpdate.newCameraPosition(
                  new CameraPosition(
                      bearing: 0,
                      tilt: 0,
                      zoom: 16.5,
                      target: LatLng(
                          newLocalData.latitude, newLocalData.longitude))));
              updateCarMarker(newLocalData, imageData, appState);
            }
          }
        }
      });
    } catch (e) {}
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    String _mapStyle =
        '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.land_parcel","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263C"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]';
    _mapController.setMapStyle(_mapStyle);
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    isActive = false;
    driverIsOnDriverScreen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.local_taxi),
          backgroundColor: isActive ? Colors.orange : Colors.black87,
          onPressed: () {
            setState(() {
              isActive = !isActive;
              Firestore.instance
                  .collection('Drivers')
                  .document(appState.phone)
                  .updateData({'isActive': isActive});
              isActive ? getCurrentLocation(appState) : clearCar();
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
                snapshot.data.documents.forEach((DocumentSnapshot user) {
                  print(user['isAskingService']);
                  if (user['isAskingService']) {
                    Firestore.instance
                        .collection('Drivers')
                        .getDocuments()
                        .then((drivers) {
                      drivers.documents.forEach((driver) async {
                        if (driver.data['currentLocation'] != null) {
                          LatLng driverLatLng = LatLng(
                              driver.data['currentLocation'].latitude,
                              driver.data['currentLocation'].longitude);
                          LatLng userLatLng = LatLng(user['origin'].latitude,
                              user['origin'].longitude);
                          print(driver.data['phone']);
                          print(await _googleMapsServices.getDistanceValue(
                              driverLatLng, userLatLng));
                        }
                      });
                    });
                  }
                });
              }
              return Stack(children: <Widget>[
                GoogleMap(
                  compassEnabled: false,
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: appState.initialPosition, zoom: 15),
                  onMapCreated: onMapCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: Set.of((_marker != null ? [_marker] : [])),
                ),
                isActive && snapshot.data.documents[0]['isAskingService']
                    ? DriverFooter(
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
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                ),
              ]);
            }));
  }
}

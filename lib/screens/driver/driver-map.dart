import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chofer/widgets/driver/driver-footer.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMapState createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  bool driverIsActive = false;
  bool driverIsOnDriverScreen = true;
  Location _location = Location();
  StreamSubscription locationSubscription;
  Marker _marker;
  GoogleMapController _mapController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String originName;
  String destinationName;
  double price;
  String distance;
  String duration;
  String userPhone;
  bool userIsAskingService = false;
  ByteData byteData;

  Future getMarker() async {
    byteData = await DefaultAssetBundle.of(context).load("assets/car.png");
  }

  void updateCarMarker(LocationData newLocalData, Uint8List imageData) async {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    await Firestore.instance
        .collection('Drivers')
        .document(await readPhoneNumber())
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

  void getCurrentLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        Uint8List imageData = byteData.buffer.asUint8List();
        var location = await _location.getLocation();
        updateCarMarker(location, imageData);

        if (locationSubscription != null) {
          locationSubscription.cancel();
        }

        locationSubscription =
            _location.onLocationChanged.listen((newLocalData) {
          if (_mapController != null) {
            if (driverIsActive) {
              if (driverIsOnDriverScreen) {
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
          }
        });
      } catch (e) {}
    });
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
    driverIsOnDriverScreen = false;
    super.dispose();
  }

  @override
  void initState() {
    getMarker();
    checkIfDriverIsActive();
    super.initState();
  }

  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<File> writePhone(String phoneNumber) async {
    final file = await _localFileNumber;
    return file.writeAsString('$phoneNumber');
  }

  Future<String> readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  void checkIfDriverIsActive() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Firestore.instance
          .collection('Drivers')
          .document(await readPhoneNumber())
          .get()
          .then((value) {
        setState(() {
          driverIsActive = value.data['isActive'];
          if (driverIsActive) {
            getCurrentLocation();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
        key: _scaffoldKey,
        drawer: MyDrawer(),
        body: StreamBuilder(
            stream: Firestore.instance.collection('Users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Container();

              if (driverIsActive) {
                snapshot.data.documents.forEach((DocumentSnapshot user) {
                  if (user['tripID'] != null) {
                    if (user['tripID']['driversList'][0]['driver'] ==
                        appState.phone) {
                      userIsAskingService = user['tripID']['isAskingService'];
                      if (userIsAskingService) {
                        print(
                            "NORMAN XXDDXD ${user['tripID']['driversList'][0]['driver']}");
                        originName = user['originName'];
                        destinationName = user['destinationName'];
                        distance = user['distance'];
                        price = double.parse(user['price'].toString());
                        userPhone = user['phone'];
                        duration = user['duration'];
                      }
                    }
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
                driverIsActive && userIsAskingService
                    ? DriverFooter(
                        origin: originName,
                        destination: destinationName,
                        price: price,
                        distance: distance,
                        duration: duration,
                        phone: userPhone)
                    : Container(),
                Positioned(
                  left: 8,
                  top: 25,
                  child: IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                ),
                DraggableScrollableSheet(
                    expand: true,
                    maxChildSize: 0.1,
                    initialChildSize: 0.1,
                    minChildSize: 0.1,
                    builder: (context, controller) {
                      return InkWell(
                          onTap: () {
                            setState(() {
                              driverIsActive = !driverIsActive;
                              Firestore.instance
                                  .collection('Drivers')
                                  .document(appState.phone)
                                  .updateData({'isActive': driverIsActive});
                              driverIsActive
                                  ? getCurrentLocation()
                                  : clearCar();
                            });
                          },
                          child: Container(
                              color: Colors.black,
                              child: ListView(
                                children: <Widget>[
                                  Text(
                                    !driverIsActive
                                        ? 'Estás desconectado'
                                        : 'Conectado. Buscando viajes ...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )));
                    })
              ]);
            }));
  }
}

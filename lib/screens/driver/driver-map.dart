import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chofer/widgets/driver/driver-accepted-footer.dart';
import 'package:chofer/widgets/driver/driver-request-footer.dart';
import 'package:chofer/widgets/driver/driver-started-footer.dart';
import 'package:chofer/widgets/map/mapStyle.dart';
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
  MapStyle mapStyle = MapStyle();
  bool driverIsActive = false;
  bool driverIsOnDriverScreen = true;
  bool driverAcceptedService = false;
  bool driverStartedService = false;
  bool driverFinishedService = false;
  String userPhone;
  Location _location = new Location();
  StreamSubscription locationSubscription;
  Set<Marker> _markers = Set<Marker>();
  GoogleMapController _mapController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String originName;
  String destinationName;
  int price;
  String distance;
  String duration;
  String userName;
  LatLng userOrigin;
  LatLng userDestination;
  ByteData byteData;
  String driverPhone;
  bool userIsAskingService = false;
  bool requestAlertIsOpen = false;
  // Set<Polyline> polyLines;

  void acceptService() async {
    bool isAlreadyAccepted = false;
    await Firestore.instance
        .collection('Drivers')
        .getDocuments()
        .then((drivers) {
      drivers.documents.forEach((driver) {
        if (driver.data['tripID']['userID'] == userPhone &&
            driver.data['tripID']['serviceAccepted']) {
          isAlreadyAccepted = true;
        }
      });
    });
    if (!isAlreadyAccepted) {
      await Firestore.instance
          .collection('Drivers')
          .document(driverPhone)
          .updateData({
        'tripID': {
          'userID': userPhone,
          'serviceAccepted': true,
          'serviceStarted': false,
          'serviceFinished': false
        }
      }).then((_) {
        setState(() {
          driverAcceptedService = true;
          driverFinishedService = false;
          driverStartedService = false;
        });
      });
    } else {
      showAlreadyAccepted(context);
    }
  }

  void showAlreadyAccepted(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Otro chofer ya aceptó el viaje",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            content: FlatButton(
              color: Colors.orange,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ),
            ));
      },
    );
  }

  void startService() {
    setState(() {
      driverStartedService = true;
    });
  }

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
    _markers = Set<Marker>();
    if (userDestination != null) {
      _markers.add(Marker(
          markerId: MarkerId(Uuid().v1()),
          position: userDestination,
          infoWindow: InfoWindow(title: "Destino", snippet: destinationName),
          icon: BitmapDescriptor.defaultMarker));
    }
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(Uuid().v1()),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));

      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: newLocalData.heading.toDouble(),
          target: LatLng(latlng.latitude, latlng.longitude),
          zoom: 16.0,
        ),
      ));
    });
  }

  void clearCar() {
    setState(() {
      _markers = Set<Marker>();
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = byteData.buffer.asUint8List();

      if (locationSubscription != null) {
        locationSubscription.cancel();
      }

      locationSubscription = _location.onLocationChanged.listen((newLocalData) {
        if (_mapController != null) {
          if (driverIsActive) {
            if (driverIsOnDriverScreen) {
              _mapController.animateCamera(CameraUpdate.newCameraPosition(
                  new CameraPosition(
                      bearing: 0,
                      tilt: 0,
                      zoom: 16,
                      target: LatLng(
                          newLocalData.latitude, newLocalData.longitude))));
              updateCarMarker(newLocalData, imageData);
            }
          }
        }
      });
    } catch (e) {}
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(mapStyle.getMapStyle());
  }

  Future getDriverPhoneNumber() async {
    driverPhone = await readPhoneNumber();
  }

  void driverCancelService() {
    driverAcceptedService = false;
    userIsAskingService = false;
    userPhone = '';
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
    getDriverPhoneNumber();
    checkDriverData();
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

  Future checkDriverData() async {
    await Firestore.instance
        .collection('Drivers')
        .document(await readPhoneNumber())
        .get()
        .then((driver) {
      setState(() {
        driverIsActive = driver['isActive'];
        if (driverIsActive) {
          getCurrentLocation();
        }
        if (driver.data['tripID'] != null) {
          driverAcceptedService = driver['tripID']['serviceAccepted'];
          driverStartedService = driver['tripID']['serviceStarted'];
          driverFinishedService = driver['tripID']['serviceFinished'];
          userPhone = driver['tripID']['userID'];
        }
      });
    });
    if (userPhone.isNotEmpty) {
      await Firestore.instance
          .collection('Users')
          .document(userPhone)
          .get()
          .then((user) {
        originName = user['trip']['originName'];
        destinationName = user['trip']['destinationName'];
        distance = user['trip']['distance'];
        price = int.parse(user['trip']['price'].toString());
        userPhone = user['phone'];
        duration = user['trip']['duration'];
        userName = user['name'];
      });
    }
  }

  void _setUserData(dynamic user) {
    originName = user['trip']['originName'];
    destinationName = user['trip']['destinationName'];
    distance = user['trip']['distance'];
    price = int.parse(user['trip']['price'].toString());
    userPhone = user['phone'];
    duration = user['trip']['duration'];
    userName = user['name'];
    userDestination = new LatLng(user['trip']['destination'].latitude,
        user['trip']['destination'].longitude);
    userOrigin = new LatLng(
        user['trip']['origin'].latitude, user['trip']['origin'].longitude);
  }

  Future _handleUsers(dynamic user, AppState appState) async {
    if (user['tripID'] != null) {
      if (user['tripID']['isAskingService']) {
        if (user['tripID']['driversList'].length != 0) {
          if (user['tripID']['driversList'][0]['driver'] == appState.phone) {
            userIsAskingService = true;
            requestAlertIsOpen = true;
            if (user['trip'] != null) {
              if (!driverAcceptedService) {
                _setUserData(user);
              }
            }
          }
        }
      }
      if (user['phone'] == userPhone) {
        userIsAskingService = user['tripID']['isAskingService'];
      }
    }
  }

  void closeAlert() {
    requestAlertIsOpen = false;
  }

  void openAlert() {
    requestAlertIsOpen = true;
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
                  _handleUsers(user, appState);
                });
              }
              return Stack(children: <Widget>[
                GoogleMap(
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: appState.initialPosition, zoom: 15),
                  onMapCreated: onMapCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                ),
                Positioned(
                  left: 8,
                  top: 25,
                  child: IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                ),
                driverIsActive &&
                        driverAcceptedService &&
                        !driverStartedService &&
                        !driverFinishedService
                    ? DriverAcceptedFooter(
                        destination: destinationName,
                        userDestination: userDestination,
                        userOrigin: userOrigin,
                        distance: distance,
                        duration: duration,
                        origin: originName,
                        price: price,
                        driverPhone: driverPhone,
                        driverCancelService: driverCancelService,
                        userName: userName,
                        userPhone: userPhone,
                        userIsAskingService: userIsAskingService,
                        startService: startService)
                    : driverIsActive &&
                            driverAcceptedService &&
                            driverStartedService
                        ? DriverStartedFooter(
                            destination: destinationName,
                            distance: distance,
                            driverPhone: driverPhone,
                            duration: duration,
                            origin: originName,
                            price: price,
                            userName: userName,
                            userPhone: userPhone)
                        : !requestAlertIsOpen
                            ? DraggableScrollableSheet(
                                expand: true,
                                maxChildSize: 0.1,
                                initialChildSize: 0.1,
                                minChildSize: 0.1,
                                builder: (context, controller) {
                                  return InkWell(
                                      onTap: () async {
                                        setState(() {
                                          driverIsActive = !driverIsActive;
                                        });
                                        await Firestore.instance
                                            .collection('Drivers')
                                            .document(appState.phone)
                                            .updateData(
                                                {'isActive': driverIsActive});

                                        driverIsActive
                                            ? getCurrentLocation()
                                            : clearCar();
                                      },
                                      child: Container(
                                          color: Colors.black54,
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )));
                                })
                            : driverIsActive &&
                                    userIsAskingService &&
                                    !driverAcceptedService &&
                                    requestAlertIsOpen
                                ? DriverRequestFooter(
                                    origin: originName,
                                    destination: destinationName,
                                    price: price,
                                    distance: distance,
                                    duration: duration,
                                    closeAlert: closeAlert,
                                    openAlert: openAlert,
                                    phone: userPhone,
                                    acceptService: acceptService,
                                  )
                                : Container(),
              ]);
            }));
  }
}

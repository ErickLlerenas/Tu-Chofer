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
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  LatLng driverOrigin;
  Set<Polyline> polyLines;
  Timer timer;

  void acceptService(String encondedPoly, Color color) async {
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
          createRoute(encondedPoly, color);
          driverAcceptedService = true;
          driverFinishedService = false;
          driverStartedService = false;
        });
      });
    } else {
      showAlreadyAccepted(context);
    }
  }

  void createRoute(String encondedPoly, Color color) {
    polyLines = Set<Polyline>();
    polyLines.add(Polyline(
        polylineId: PolylineId(Uuid().v1()),
        width: 3,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: color));
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    return lList;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
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

  Future startService() async {
    Color color = Colors.red;
    setState(() {
      driverStartedService = true;
    });
    Map answer = await getRouteDistanceAndDuration(userOrigin, userDestination);
    createRoute(answer['route'], color);
  }

  Future<Map> getRouteDistanceAndDuration(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    Map answer = {
      'route': values["routes"][0]["overview_polyline"]["points"],
      'distanceText': values["routes"][0]["legs"][0]["distance"]["text"],
      'durationText': values["routes"][0]["legs"][0]["duration"]["text"],
      'distanceValue': values["routes"][0]["legs"][0]["distance"]["value"],
      'durationValue': values["routes"][0]["legs"][0]["duration"]["value"]
    };
    return answer;
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
    if (!driverStartedService) {
      if (userOrigin != null) {
        _markers.add(Marker(
            markerId: MarkerId(Uuid().v1()),
            position: userOrigin,
            infoWindow: InfoWindow(title: "Destino", snippet: destinationName),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure)));
      }
    } else {
      if (userDestination != null) {
        _markers.add(Marker(
            markerId: MarkerId(Uuid().v1()),
            position: userDestination,
            infoWindow: InfoWindow(title: "Destino", snippet: destinationName),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed)));
      }
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
              driverOrigin =
                  LatLng(newLocalData.latitude, newLocalData.longitude);
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

  void checkDriverActive() async {
    await Firestore.instance
        .collection('Drivers')
        .document(driverPhone)
        .get()
        .then((value) {
      if (value.exists) {
        driverIsActive = value.data['isActive'];
        if (driverIsActive) {
          getCurrentLocation();
          Wakelock.enable();
        } else {
          clearCar();
          Wakelock.disable();
        }
      }
    });
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    driverIsOnDriverScreen = false;
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    getMarker();
    timer =
        Timer.periodic(Duration(seconds: 5), (Timer t) => checkDriverActive());
    getDriverPhoneNumber();
    checkDriverData();
    super.initState();
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
                    polylines: polyLines),
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

                                        if (driverIsActive) {
                                          getCurrentLocation();
                                          Wakelock.enable();
                                        } else {
                                          clearCar();
                                          Wakelock.disable();
                                        }
                                      },
                                      child: Container(
                                          color: Colors.black54,
                                          child: ListView(
                                            children: <Widget>[
                                              Text(
                                                !driverIsActive
                                                    ? 'Estás desconectado'
                                                    : 'Conectado, buscando viajes..',
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
                                    userOrigin: userOrigin,
                                    driverOrigin: driverOrigin,
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

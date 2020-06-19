import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chofer/requests/google-maps-requests.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as l;

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  Set<Marker> _markers;
  Set<Polyline> _polyLines;
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  LatLng destination;
  LatLng origin;
  String distance = "...";
  String duration = "...";
  int distanceValue;
  int durationValue;
  int precio;
  bool isLoadingPrices;
  l.Location location = new l.Location();
  bool serviceEnabled = true;
  l.PermissionStatus _permissionGranted;

  AppState() {
    hasAlreadyPermissionsAndService();
  }

  //  TO GET THE USERS LOCATION
  void getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    print(
        "the latitude is: ${position.longitude} and th longitude is: ${position.longitude} ");
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].thoroughfare +
        " " +
        placemark[0].name +
        ", " +
        placemark[0].subLocality +
        ", " +
        placemark[0].locality +
        ", " +
        placemark[0].administrativeArea +
        ", " +
        placemark[0].country;
    notifyListeners();
  }

  //  TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines = {};
    _polyLines.add(Polyline(
        polylineId: PolylineId(Uuid().v1()),
        width: 3,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.black));
    notifyListeners();
  }

  //  ADD A MARKER ON THE MAP
  void _addMarker(LatLng location, String address) {
    _markers = {};
    _markers.add(Marker(
        markerId: MarkerId(Uuid().v1()),
        position: location,
        infoWindow: InfoWindow(title: "Destino", snippet: address),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  //  CREATE LAGLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // DECODE POLY (THIS FUNCTION IS PROVIDED BY GOOGLE)
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
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

    print(lList.toString());

    return lList;
  }

  //  SEND REQUEST
  void sendRequest(String intendedLocation) async {
    isLoadingPrices = false;
    precio = 30;
    origin = _initialPosition;
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    distance =
        await _googleMapsServices.getDistance(_initialPosition, destination);
    duration =
        await _googleMapsServices.getDuration(_initialPosition, destination);
    durationValue = await _googleMapsServices.getDurationValue(
        _initialPosition, destination);
    distanceValue = await _googleMapsServices.getDistanceValue(
        _initialPosition, destination);

    if (distanceValue > 3000) {
      print(distanceValue);
      precio += (((distanceValue - 3000) / 1000) * 5).toInt();
      print(precio);
    }
    isLoadingPrices = true;
    createRoute(route);
    notifyListeners();
  }

  //  ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  //  ON MAP CREATED
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // CHANGES THE ORIGIN OF THE ROUTE
  void changeOrigin(LatLng origen) async {
    origin = origen;
    isLoadingPrices = false;
    precio = 30;
    String route =
        await _googleMapsServices.getRouteCoordinates(origen, destination);
    createRoute(route);
    distance =
        await _googleMapsServices.getDistance(origen, destination);
    duration =
        await _googleMapsServices.getDuration(origen, destination);
    durationValue = await _googleMapsServices.getDurationValue(
        origen, destination);
    distanceValue = await _googleMapsServices.getDistanceValue(
        origen, destination);
    if (distanceValue > 3000) {
      print(distanceValue);
      precio += (((distanceValue - 3000) / 1000) * 5).toInt();
      print(precio);
    }
    isLoadingPrices = true;
    notifyListeners();
  }

  // CHANGES THE DESTINATION OF THE ROUTE
  void changeDestination(LatLng dest,intendedLocation)async{
    destination = dest;
    isLoadingPrices = false;
    precio = 30;
    String route =
        await _googleMapsServices.getRouteCoordinates(origin, dest);
    createRoute(route);
    distance =
        await _googleMapsServices.getDistance(origin, dest);
    duration =
        await _googleMapsServices.getDuration(origin, dest);
    durationValue = await _googleMapsServices.getDurationValue(
        origin, dest);
    distanceValue = await _googleMapsServices.getDistanceValue(
        origin, dest);
    if (distanceValue > 3000) {
      print(distanceValue);
      precio += (((distanceValue - 3000) / 1000) * 5).toInt();
      print(precio);
    }
    isLoadingPrices = true;
    _addMarker(dest, intendedLocation);
    notifyListeners();
  }

  // CHECKS IF THE USER HAS PERMISSIONS AND THE LOCATION ACTIVE
  void hasAlreadyPermissionsAndService() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == l.PermissionStatus.granted) {
      serviceEnabled = await location.serviceEnabled();
      if (serviceEnabled) {
        getUserLocation();
      }
    }
  }
  
}

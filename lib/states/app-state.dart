import 'dart:io';
import 'dart:typed_data';
import 'package:chofer/screens/driver/driver-request-pending.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chofer/requests/google-maps-requests.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as l;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  Set<Marker> _markers = Set<Marker>();
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
  String distance;
  String duration;
  int distanceValue;
  int durationValue;
  String route;

  bool isLoadingPrices = false;
  List driverHistory = [];
  List userMessages = [];
  List driverMessages = [];
  l.Location location = new l.Location();
  bool serviceEnabled = true;
  l.PermissionStatus permissionGranted;
  String _phone;
  String _name;
  String tempName;
  bool validName = true;
  bool validAddres = true;
  bool validCarName = true;
  bool validCarModel = true;
  bool validCarPlates = true;
  bool userWantsToBeDriver = false;
  bool userIsDriver = false;
  bool isAskingService = false;
  bool serviceAccepted = false;
  bool serviceStarted = false;
  bool serviceFinished = false;
  File image;
  File carImage;
  String downloadURL = "";
  String address;
  String carName;
  String carModel;
  String carPlates;
  TextEditingController nameController;
  TextEditingController registerNameController;
  TextEditingController addressController;
  TextEditingController carNameController;
  TextEditingController carModelController;
  TextEditingController carPlatesController;
  // String _locality;
  final picker = ImagePicker();
  int costoServicio;
  int costoBase;
  double costoKilometro;
  double costoMinuto;
  int runPopOnceHack = 0;
  ByteData carMarker;

  String driverCarName;
  String driverCarImage;
  String driverName;
  String driverCarModel;
  String driverImage;
  String driverPhone;
  String driverCarPlates;

  get phone => _phone;
  get name => _name;

  AppState() {
    _checkIfUserHasPermissionGrantedAndServiceEnabled();
    getPhoneNumber();
    getUserName();
  }

  Future getPhoneNumber() async {
    _phone = await _readPhoneNumber();
    if (_phone.isNotEmpty) {
      _getDownloadProfilePictureURL(_phone);
      _checkIfIsDriver(_phone);
    }
    notifyListeners();
  }

  Future getUserName() async {
    _name = await readName();
    tempName = _name;
    notifyListeners();
  }

  Future _getCurrentServicePricing() async {
    await Firestore.instance
        .collection('Prices')
        .document('actualPrices')
        .get()
        .then((value) {
      costoBase = value.data['costoBase'];
      costoKilometro = value.data['costoKilometro'];
      costoServicio = value.data['costoServicio'];
      costoMinuto = value.data['costoMinuto'];
      notifyListeners();
    });
  }

  Future _getDestinationLatLng(intendedLocation) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    destination = LatLng(latitude, longitude);
    notifyListeners();
  }

  Future _getRouteDistanceAndDurationValues() async {
    Map answer = await _googleMapsServices.getRouteDistanceAndDuration(
        origin, destination);

    route = answer['route'];
    distance = answer['distanceText'];
    duration = answer['durationText'];
    distanceValue = answer['distanceValue'];
    durationValue = answer['durationValue'];
    notifyListeners();
  }

  void _calculatePricing() {
    if (distanceValue > 3000) {
      // _locality = placemark[0].locality;
      // if (_locality == "Comala") {
      //   costoBase += 10;
      // }

      costoServicio += ((((distanceValue - 3000) / 1000) * costoKilometro) +
              costoBase +
              (durationValue / 60 * costoMinuto))
          .toInt();
    }
    notifyListeners();
  }

  void getUserLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemark = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      _initialPosition = LatLng(position.latitude, position.longitude);
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
    } catch (error) {}
    notifyListeners();
  }

  void _createRoute(String encondedPoly) {
    _polyLines = Set<Polyline>();
    _polyLines.add(Polyline(
        polylineId: PolylineId(Uuid().v1()),
        width: 3,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.black));
    notifyListeners();
  }

  void _addMarker(LatLng location, String address) {
    _markers = Set<Marker>();
    _markers.add(Marker(
        markerId: MarkerId(Uuid().v1()),
        position: location,
        infoWindow: InfoWindow(title: "Destino", snippet: address),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
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

  //THIS FUNCTION IS PROVIDED BY GOOGLE, DON'T CHANGE IT!!
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

    return lList;
  }

  void sendRequest(String intendedLocation, context) async {
    isLoadingPrices = true;
    destinationController.text = intendedLocation;
    origin = _initialPosition;
    await _getCurrentServicePricing();
    await _getDestinationLatLng(intendedLocation);
    await _getRouteDistanceAndDurationValues();
    _addMarker(destination, intendedLocation);
    _calculatePricing();
    _createRoute(route);
    isLoadingPrices = false;
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    String _mapStyle =
        '[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#7c93a3" }, { "lightness": "-10" } ] }, { "featureType": "administrative.country", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] }, { "featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [ { "color": "#a0a4a5" } ] }, { "featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [ { "color": "#62838e" } ] }, { "featureType": "landscape", "elementType": "geometry.fill", "stylers": [ { "color": "#dde3e3" } ] }, { "featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [ { "color": "#3f4a51" }, { "weight": "0.30" } ] }, { "featureType": "poi", "elementType": "all", "stylers": [ { "visibility": "simplified" } ] }, { "featureType": "poi.attraction", "elementType": "all", "stylers": [ { "visibility": "on" } ] }, { "featureType": "poi.business", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "poi.government", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "poi.park", "elementType": "all", "stylers": [ { "visibility": "on" } ] }, { "featureType": "poi.place_of_worship", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "poi.school", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "poi.sports_complex", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "road", "elementType": "all", "stylers": [ { "saturation": "-100" }, { "visibility": "on" } ] }, { "featureType": "road", "elementType": "geometry.stroke", "stylers": [ { "visibility": "on" } ] }, { "featureType": "road.highway", "elementType": "geometry.fill", "stylers": [ { "color": "#bbcacf" } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "lightness": "0" }, { "color": "#bbcacf" }, { "weight": "0.50" } ] }, { "featureType": "road.highway", "elementType": "labels", "stylers": [ { "visibility": "on" } ] }, { "featureType": "road.highway", "elementType": "labels.text", "stylers": [ { "visibility": "on" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry.stroke", "stylers": [ { "color": "#a9b4b8" } ] }, { "featureType": "road.arterial", "elementType": "labels.icon", "stylers": [ { "invert_lightness": true }, { "saturation": "-7" }, { "lightness": "3" }, { "gamma": "1.80" }, { "weight": "0.01" } ] }, { "featureType": "transit", "elementType": "all", "stylers": [ { "visibility": "off" } ] }, { "featureType": "water", "elementType": "geometry.fill", "stylers": [ { "color": "#a3c7df" } ] } ]';
    _mapController.setMapStyle(_mapStyle);
    notifyListeners();
  }

  void changeOrigin(LatLng newOrigin) async {
    isLoadingPrices = true;
    origin = newOrigin;
    await _getCurrentServicePricing();
    await _getRouteDistanceAndDurationValues();
    _createRoute(route);
    _calculatePricing();
    isLoadingPrices = false;
    notifyListeners();
  }

  void changeDestination(LatLng newDestination, intendedLocation) async {
    isLoadingPrices = true;
    destination = newDestination;
    await _getCurrentServicePricing();
    await _getRouteDistanceAndDurationValues();
    _addMarker(destination, intendedLocation);
    _createRoute(route);
    _calculatePricing();
    isLoadingPrices = false;
    notifyListeners();
  }

  void _checkIfUserHasPermissionGrantedAndServiceEnabled() async {
    permissionGranted = await location.hasPermission();
    if (permissionGranted == l.PermissionStatus.granted) {
      serviceEnabled = await location.serviceEnabled();
      if (serviceEnabled) {
        getUserLocation();
      } else {
        serviceEnabled = false;
      }
    } else {
      serviceEnabled = false;
    }
    notifyListeners();
  }

  Future getCarMarker(BuildContext context) async {
    carMarker = await DefaultAssetBundle.of(context).load("assets/car.png");
    notifyListeners();
  }

  void updateCarMarkers(List cars, BuildContext context) async {
    _markers = Set<Marker>();

    cars.forEach((car) {
      LatLng latlng = LatLng(
          car['currentLocation'].latitude, car['currentLocation'].longitude);
      _markers.add(Marker(
          markerId: MarkerId(Uuid().v1()),
          position: latlng,
          rotation: car['currentLocationHeading'].toDouble(),
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(carMarker.buffer.asUint8List())));
    });
    notifyListeners();
  }

  void validateNameInput(bool isValid, String newName) {
    validName = isValid;
    tempName = newName;
    notifyListeners();
  }

  void validateAddresInput(bool isValid, String newAddress) {
    validAddres = isValid;
    address = newAddress;
    notifyListeners();
  }

  void validateCarName(bool isValid, String newName) {
    validCarName = isValid;
    carName = newName;
    notifyListeners();
  }

  void validateCarModel(bool isValid, String newModel) {
    validCarModel = isValid;
    carModel = newModel;
    notifyListeners();
  }

  void validateCarPlates(bool isValid, String newPlates) {
    validCarPlates = isValid;
    carPlates = newPlates;
    notifyListeners();
  }

  Future saveName(String id, String newName, BuildContext context) async {
    _name = newName;
    await writeName(newName);
    await Firestore.instance
        .collection('Users')
        .document(id)
        .updateData({'name': newName});
    notifyListeners();
    Toast.show("Nombre guardado", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 3000,
        maxWidth: 3000);
    if (pickedFile != null) image = File(pickedFile.path);
    notifyListeners();
  }

  Future getCarImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 3000,
        maxWidth: 3000);
    if (pickedFile != null) carImage = File(pickedFile.path);
    notifyListeners();
  }

  Future _getDownloadProfilePictureURL(number) async {
    try {
      await Firestore.instance
          .collection('Users')
          .document(phone)
          .get()
          .then((doc) {
        if (doc.exists) {
          if (doc['image'] != null) {
            downloadURL = doc['image'];
          }
        }
      });

      notifyListeners();
    } catch (error) {}
  }

  Future saveUserProfilePicture(BuildContext context, String phone) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(phone);
    if (image != null) {
      _showLoadingPhotoDialog(context);
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      if (uploadTask.isComplete) {
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(phone);
        downloadURL = await storageReference.getDownloadURL();
        Firestore.instance
            .collection('Users')
            .document(phone)
            .updateData({'image': downloadURL});
        if (userIsDriver) {
          Firestore.instance
              .collection('Drivers')
              .document(phone)
              .updateData({'image': downloadURL});
        }
        image = null;
        Navigator.pop(context);
        Toast.show("Foto guardada", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
    notifyListeners();
  }

  Future _saveDriverProfilePicture(BuildContext context, String phone) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(phone);
    if (image != null) {
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      if (uploadTask.isComplete) {
        String url = await storageReference.getDownloadURL();
        await Firestore.instance
            .collection('Drivers')
            .document(phone)
            .updateData({'image': url});

        //Save the user image too!!
        await Firestore.instance
            .collection('Users')
            .document(phone)
            .updateData({'image': url});
        image = null;
        await _getDownloadProfilePictureURL(phone);
      }
    } else {
      await Firestore.instance
          .collection('Drivers')
          .document(phone)
          .updateData({'image': downloadURL});
    }
    notifyListeners();
  }

  void _getDriverData(driver) {
    driverCarName = driver['carName'];
    driverCarImage = driver['car'];
    driverName = driver['name'];
    driverCarModel = driver['carModel'];
    driverImage = driver['image'];
    driverPhone = driver['phone'];
    driverCarPlates = driver['carPlates'];
    if (driver['tripID'] != null) {
      serviceStarted = driver['tripID']['serviceStarted'];
      serviceFinished = driver['tripID']['serviceFinished'];
      serviceAccepted = driver['tripID']['serviceAccepted'];
    }

    notifyListeners();
  }

  void _showLoadingPhotoDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Guardando foto de perfil...",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: LinearProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
            ));
      },
    );
    notifyListeners();
  }

  void _showLoadingDriverRquest(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Enviando solicutud...",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: LinearProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
            ));
      },
    );
    notifyListeners();
  }

  void showImageAlertDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "$message",
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
    notifyListeners();
  }

  void getCurrentLocationAndAnimateCamera() async {
    l.LocationData currentLocation;
    var location = new l.Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.0,
      ),
    ));
    notifyListeners();
  }

  // Save data for next screen
  Future nextScreen(String name, String _address) async {
    address = _address;
    _name = name;
    notifyListeners();
  }

  Future saveDriverDataRequest(
      String id,
      String name,
      String _address,
      String carName,
      String carModel,
      String carPlates,
      BuildContext context) async {
    try {
      writeName(name);
      _showLoadingDriverRquest(context);
      await Firestore.instance
          .collection('Users')
          .document(id)
          .updateData({'name': name});

      await Firestore.instance.collection('Drivers').document(id).setData({
        'address': _address,
        'carName': carName,
        'carModel': carModel,
        'carPlates': carPlates,
        'history': [],
        'isAccepted': false,
        'isActive': false,
        'name': name,
        'phone': phone,
        'messages': [
          {
            'name': 'Tu Chofer',
            'message':
                'Hola ${name.split(' ')[0]}, aquí podrás chatear con nosotros y nosotros comunicarnos contigo'
          }
        ],
        'tripID': {
          'serviceAccepted': false,
          'serviceFinished': false,
          'serviceStarted': false,
          'userID': ''
        }
      });
      await _saveDriverProfilePicture(context, phone);
      await _saveCarPicture(context, phone);
      //Update state, now the user wants to be a driver
      userWantsToBeDriver = true;
      notifyListeners();
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DriverRequestPending()));
    } catch (error) {}
  }

  Future _saveCarPicture(BuildContext context, String phone) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("driver" + phone);
    if (carImage != null) {
      StorageUploadTask uploadTask = storageReference.putFile(carImage);
      await uploadTask.onComplete;
      if (uploadTask.isComplete) {
        String url = await storageReference.getDownloadURL();
        await Firestore.instance
            .collection('Drivers')
            .document(phone)
            .updateData({'car': url});
      }
    }
    notifyListeners();
  }

  Future _checkIfIsDriver(String driverID) async {
    try {
      await Firestore.instance
          .collection('Drivers')
          .document(driverID)
          .get()
          .then((driver) {
        if (driver.exists) {
          if (driver.data['isAccepted']) {
            //The user is a Driver and is accepted
            userIsDriver = true;
          } else {
            //The user wants to be a driver and is waiting for beeing accepted
            userWantsToBeDriver = true;
            userIsDriver = false;
          }
        } else {
          //The user is a normal user
          userIsDriver = false;
          userWantsToBeDriver = false;
        }
        notifyListeners();
      });
    } catch (e) {}
  }

  Future cancelDriverRequest() async {
    try {
      await Firestore.instance.collection('Drivers').document(_phone).delete();
      userWantsToBeDriver = false;
      notifyListeners();
    } catch (e) {}
  }

  void userIsAskingService(bool isAsking) {
    isAskingService = isAsking;
    notifyListeners();
  }

  void _hackToRunPopOnce(BuildContext context) async {
    runPopOnceHack++;
    Navigator.of(context).maybePop();
    serviceAccepted = true;
    await Firestore.instance.collection('Users').document(phone).updateData({
      'tripID': {'isAskingService': true, 'driversList': []}
    });
    notifyListeners();
  }

  Future _checkIfDriverAccepted(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) async {
    snapshot.data.documents.forEach((DocumentSnapshot driver) {
      if (isAskingService) {
        if (driver['tripID']['userID'] == phone &&
            driver['tripID']['serviceAccepted']) {
          if (runPopOnceHack == 0) {
            _hackToRunPopOnce(context);
          }
          _getDriverData(driver);
        }
      }
    });
    notifyListeners();
  }

  List _getDriversCarsPosition(AsyncSnapshot<QuerySnapshot> snapshot) {
    var carsPosition = [];
    snapshot.data.documents.forEach((DocumentSnapshot driver) {
      if (driver['currentLocation'] != null) {
        if (driver['isActive']) {
          carsPosition.add({
            'currentLocation': driver['currentLocation'],
            'currentLocationHeading': driver['currentLocationHeading']
          });
        }
      }
    });
    return carsPosition;
  }

  Future cancelService() async {
    await Firestore.instance.collection('Users').document(phone).updateData({
      'tripID': {'isAskingService': false, 'driversList': []}
    });
    _resetVariables();
    notifyListeners();
  }

  void _resetVariables() {
    serviceAccepted = false;
    serviceFinished = false;
    serviceStarted = false;
    isAskingService = false;
    destinationController.text = '';
    _polyLines = Set<Polyline>();
    _markers = Set<Marker>();
    runPopOnceHack = 0;
    notifyListeners();
  }

  void _getDriverPosition(snapshot) {
    var driverCar = [];
    snapshot.data.documents.forEach((DocumentSnapshot driver) {
      if (driver['currentLocation'] != null && driver['isActive']) {
        if (driver['phone'] == driverPhone) {
          _getDriverData(driver);
          driverCar.add({
            'currentLocation': driver['currentLocation'],
            'currentLocationHeading': driver['currentLocationHeading']
          });
        }
      }
    });
    updateAcceptedDriverCarMarker(driverCar);
  }

  void updateAcceptedDriverCarMarker(List driverCar) async {
    LatLng latlng = LatLng(driverCar[0]['currentLocation'].latitude,
        driverCar[0]['currentLocation'].longitude);

    //first add the destination marker
    if (destination != null) {
      _addMarker(destination, address);
      //then add the car marker

    }
    _markers.add(Marker(
        markerId: MarkerId(Uuid().v1()),
        position: latlng,
        rotation: driverCar[0]['currentLocationHeading'].toDouble(),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(carMarker.buffer.asUint8List())));

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: driverCar[0]['currentLocationHeading'].toDouble(),
        target: LatLng(driverCar[0]['currentLocation'].latitude,
            driverCar[0]['currentLocation'].longitude),
        zoom: 16.0,
      ),
    ));
    notifyListeners();
  }

  void handleStream(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    var carsPosition = [];

    //Ahorita intento sin los 5 segundos
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (destinationController.text.isEmpty) {
        carsPosition = _getDriversCarsPosition(snapshot);
        updateCarMarkers(carsPosition, context);
      }
    });
    if (destinationController.text.isNotEmpty) {
      if (isAskingService) {
        if (!serviceAccepted) {
          _checkIfDriverAccepted(snapshot, context);
        } else {
          _getDriverPosition(snapshot);
        }
      }
    }
  }

  Future getUserDataInCaseUserExitsTheApp() async {
    _phone = await _readPhoneNumber();
    if (_phone != null) {
      if (_phone.isNotEmpty) {
        await Firestore.instance
            .collection('Users')
            .document(_phone)
            .get()
            .then((user) async {
          if (user.exists) {
            if (user['tripID'] != null) {
              isAskingService = user['tripID']['isAskingService'];

              if (isAskingService &&
                  user['tripID']['driversList'].length == 0) {
                //This means the user is actually on service, because isAskingService with 0 list
                //I mean, the driver already accepted
                destinationController.text = user['trip']['destinationName'];
                destination = LatLng(user['trip']['destination'].latitude,
                    user['trip']['destination'].longitude);
              }
            }
          }
        });
      }
    }
    notifyListeners();
  }

  // SAVE TO LOCAL FILE FUNCTIONS:
  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<File> writePhone(String newPhone) async {
    final file = await _localFileNumber;
    return file.writeAsString('$newPhone');
  }

  Future<String> _readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Future<String> get _localPathName async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileName async {
    final path = await _localPathName;
    return File('$path/login_name.txt');
  }

  Future<File> writeName(String userName) async {
    final file = await _localFileName;
    return file.writeAsString('$userName');
  }

  Future<String> readName() async {
    try {
      final file = await _localFileName;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }
}

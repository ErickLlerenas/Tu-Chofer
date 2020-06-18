import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:chofer/screens/Home.dart';

class LocationState with ChangeNotifier{

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;


  void enableService(appState,BuildContext context) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        appState.getUserLocation();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        return;
      }
    } else {
      appState.getUserLocation();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

   void askPermission(appState,BuildContext context) async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.granted) {
      enableService(appState,context);
    }
  }


  void hasAlreadyPermissions(appState) async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled) {
        appState.getUserLocation();
      }
    }
  }

}
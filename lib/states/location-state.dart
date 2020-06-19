import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:chofer/screens/Home.dart';

class LocationState with ChangeNotifier{

  Location location = new Location();
  bool serviceEnabled = true;
  PermissionStatus _permissionGranted;

  //ENABLES THE LOCATION DEVICE
  void enableService(appState,BuildContext context) async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled) {
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
  //ENABLES THE LOCATION PERMISSIONS
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


  

}
import 'package:chofer/requests/google-maps-requests.dart';
import 'package:chofer/screens/user/change-destination.dart';
import 'package:chofer/screens/user/change-origin.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestFooter extends StatefulWidget {
  @override
  _UserRequestFooterState createState() => _UserRequestFooterState();
}

class _UserRequestFooterState extends State<UserRequestFooter> {
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  List sortedDriversList = [];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return DraggableScrollableSheet(
        expand: true,
        maxChildSize: 0.4,
        initialChildSize: 0.4,
        minChildSize: 0.4,
        builder: (context, controller) {
          return Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeOrigin()));
                    },
                    leading: Icon(Icons.location_on, color: Colors.blue[400]),
                    title: Text("Origen"),
                    subtitle: Text('${appState.locationController.text}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeDestination()));
                    },
                    leading: Icon(Icons.location_on, color: Colors.red[400]),
                    title: Text("Destino"),
                    subtitle: Text('${appState.destinationController.text}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  !appState.isLoadingPrices
                      ? ListTile(
                          title: LinearProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.black87),
                          ),
                        )
                      : ListTile(
                          leading: Icon(
                            Icons.attach_money,
                            color: Colors.teal[400],
                          ),
                          title: Text("Precio: \$${appState.costoServicio}"),
                          subtitle: Text(
                            "Distancia: ${appState.distance}\nDuración: ${appState.duration}",
                          )),
                  !appState.isLoadingPrices
                      ? Container()
                      : ListTile(
                          subtitle: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                              color: Colors.black87,
                              child: Text(
                                'Pide tu chofer',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                _showSearchingDriversDialog(appState.phone);
                                appState.userIsAskingService();
                                await _getClosestDriversList(
                                    appState.origin, appState.phone);
                                await _updateFirestoreData(
                                    appState, sortedDriversList);
                                await _removeClosestDriverIfNotAcceptedAfter10Seconds(
                                    appState, sortedDriversList);
                              },
                            ),
                          ),
                        )
                ],
              ));
        });
  }

  void _showSearchingDriversDialog(String phone) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Text(
                "Buscando choferes...",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
              )
            ],
          ),
          content: Container(
              child: FlatButton(
            color: Colors.red[400],
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              Firestore.instance
                  .collection('Users')
                  .document('$phone')
                  .updateData({
                'tripID': {'isAskingService': false, 'driversList': []}
              });
            },
          )),
        );
      },
    );
  }

  Future _getClosestDriversList(origin, userPhone) async {
    List driversList = [];

    QuerySnapshot drivers =
        await Firestore.instance.collection('Drivers').getDocuments();

    for (var driver in drivers.documents) {
      if (driver.data['currentLocation'] != null) {
        //Set Driver LatLng
        LatLng driverLatLng = LatLng(driver.data['currentLocation'].latitude,
            driver.data['currentLocation'].longitude);

        //Set User LatLng
        LatLng userLatLng = LatLng(origin.latitude, origin.longitude);

        //Get the distance between those two Points
        var distance = await _googleMapsServices.getDistanceValue(
            driverLatLng, userLatLng);

        //Create an array with the list
        //important to compare if are not equal, other whise the user will call the same person as a driver
        if (driver['phone'] != userPhone)
          driversList.add({'distance': distance, 'driver': driver['phone']});

        //Sort the list so the nearest drivers are the firsts
        driversList.sort((a, b) => a['distance'].compareTo(b['distance']));

        //Equal the List to global list
        setState(() {
          sortedDriversList = driversList;
        });
      }
    }
  }

  Future _updateFirestoreData(AppState appState, List list) async {
    Firestore.instance.collection('Users').document(appState.phone).updateData({
      'destinationName': appState.destinationController.text,
      'originName': appState.locationController.text,
      'origin':
          new GeoPoint(appState.origin.latitude, appState.origin.longitude),
      'destination': new GeoPoint(
          appState.destination.latitude, appState.destination.longitude),
      'phone': appState.phone,
      'price': appState.costoServicio,
      'distance': appState.distance,
      'duration': appState.duration,
      'tripID': {'isAskingService': true, 'driversList': list}
    });
  }

  Future _removeClosestDriverIfNotAcceptedAfter10Seconds(
      AppState appState, List drivers) async {
    List clone = []..addAll(drivers);
    for (var driver in drivers) {
      await Future.delayed(Duration(seconds: 10));
      clone.remove(driver);
      await _updateFirestoreData(appState, clone);
    }
  }
}

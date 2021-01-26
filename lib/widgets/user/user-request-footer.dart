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
        maxChildSize: 0.45,
        initialChildSize: 0.45,
        minChildSize: 0.45,
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
                  appState.isLoadingPrices
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
                          title: appState.originIsInsideCircle &&
                                  appState.destinationIsInsideCircle
                              ? Text("Precio: \$${appState.costoServicio}")
                              : Text(
                                  "Precio: \$${appState.costoServicio}",
                                  style: TextStyle(color: Colors.red),
                                ),
                          subtitle: appState.originIsInsideCircle &&
                                  appState.destinationIsInsideCircle
                              ? Text(
                                  "Distancia: ${appState.distance}\nDuración: ${appState.duration}",
                                )
                              : Text(
                                  "Distancia: ${appState.distance}\nDuración: ${appState.duration}\nEl precio ha incrementado debido a estar fuera del rango marcado",
                                  style: TextStyle(color: Colors.red),
                                )),
                  appState.isLoadingPrices
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
                                _handlePressed(appState);
                              },
                            ),
                          ),
                        )
                ],
              ));
        });
  }

  void _showSearchingDriversDialog(String phone, AppState appState) {
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
              Navigator.of(context).maybePop();
            },
          )),
        );
      },
    ).then((value) {
      if (!appState.serviceAccepted) {
        appState.userIsAskingService(false);
        Firestore.instance.collection('Users').document('$phone').updateData({
          'tripID': {'isAskingService': false, 'driversList': []}
        });
      }
    });
  }

  Future _getClosestDriversList(origin, userPhone) async {
    List driversList = [];

    QuerySnapshot drivers =
        await Firestore.instance.collection('Drivers').getDocuments();

    for (var driver in drivers.documents) {
      if (driver['currentLocation'] != null) {
        if (driver['isActive'] && driver['isAccepted']) {
          if (driver['phone'] != userPhone) {
            if (driver['tripID'] != null) {
              if (!driver['tripID']['serviceAccepted']) {
                //Set Driver LatLng
                LatLng driverLatLng = LatLng(driver['currentLocation'].latitude,
                    driver['currentLocation'].longitude);

                //Set User LatLng
                LatLng userLatLng = LatLng(origin.latitude, origin.longitude);

                //Get the distance between those two Points
                var distance = await _googleMapsServices.getDistanceValue(
                    driverLatLng, userLatLng);

                //Create an array with the list
                driversList
                    .add({'distance': distance, 'driver': driver['phone']});

                //Sort the list so the nearest drivers are the firsts
                driversList
                    .sort((a, b) => a['distance'].compareTo(b['distance']));

                //Equal the List to global list
                sortedDriversList = driversList;
                print(driversList);
              }
            }
          }
        }
      }
    }
  }

  Future _updateFirestoreData(
      AppState appState, List list, bool isAskingService) async {
    if (appState.isAskingService && !appState.serviceAccepted) {
      await Firestore.instance
          .collection('Users')
          .document(appState.phone)
          .updateData({
        'tripID': {'isAskingService': isAskingService, 'driversList': list},
        'trip': {
          'destinationName': appState.destinationController.text,
          'originName': appState.locationController.text,
          'origin':
              new GeoPoint(appState.origin.latitude, appState.origin.longitude),
          'destination': new GeoPoint(
              appState.destination.latitude, appState.destination.longitude),
          'price': appState.costoServicio,
          'distance': appState.distance,
          'duration': appState.duration,
        }
      });
    }
  }

  Future _removeClosestDriverIfNotAccepted(
      AppState appState, List drivers) async {
    List clone = []..addAll(drivers);
    if (appState.isAskingService && !appState.serviceAccepted) {
      await _updateFirestoreData(appState, clone, true);
      if (clone.length == 0) {
        Navigator.of(context).pop();
        _showNotDriversAvailable(context);
      }
      for (var driver in drivers) {
        await Future.delayed(Duration(seconds: 11));

        if (appState.serviceAccepted) {
          await _updateFirestoreData(appState, [], true);
          break;
        }

        if (!appState.isAskingService) {
          await _updateFirestoreData(appState, [], false);
          break;
        }

        if (appState.isAskingService && !appState.serviceAccepted) {
          clone.remove(driver);
          await _updateFirestoreData(appState, clone, true);
          if (clone.length == 0) {
            Navigator.of(context).pop();
            _showNotDriversAvailable(context);
          }
        } else {
          break;
        }
      }
    }
  }

  void _showNotDriversAvailable(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Choferes no disponibles.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
              "Por el momento no hay algún chofer disponible, puedes volver a intentarlo más tarde."),
          actions: [
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future _handlePressed(appState) async {
    sortedDriversList = [];
    //Show Loading Dialog
    _showSearchingDriversDialog(appState.phone, appState);

    //Set state user is actually calling a service
    appState.userIsAskingService(true);

    //Get an ordered list of the drivers position
    await _getClosestDriversList(appState.origin, appState.phone);

    // //Save that data to firebase
    // await _updateFirestoreData(appState, sortedDriversList, true);

    //Create the algorithm
    await _removeClosestDriverIfNotAccepted(appState, sortedDriversList);
  }
}

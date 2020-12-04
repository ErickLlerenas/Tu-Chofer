import 'package:chofer/screens/user/change-destination.dart';
import 'package:chofer/screens/user/change-origin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestFooter extends StatefulWidget {
  final String driverImage;
  final String driverName;
  final String driverCarImage;
  final String driverCarName;
  final String driverCarPlates;
  final String driverPhone;
  UserRequestFooter(
      {this.driverCarImage,
      this.driverCarName,
      this.driverCarPlates,
      this.driverImage,
      this.driverName,
      this.driverPhone});
  @override
  _UserRequestFooterState createState() => _UserRequestFooterState();
}

class _UserRequestFooterState extends State<UserRequestFooter> {
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
                              onPressed: () {
                                _showSearchingDriversDialog(appState.phone);
                                appState.userIsAskingService();
                                Firestore.instance
                                    .collection('Users')
                                    .document(appState.phone)
                                    .updateData({
                                  'isAskingService': true,
                                  'destinationName':
                                      appState.destinationController.text,
                                  'originName':
                                      appState.locationController.text,
                                  'origin': new GeoPoint(
                                      appState.origin.latitude,
                                      appState.origin.longitude),
                                  'destination': new GeoPoint(
                                      appState.destination.latitude,
                                      appState.destination.longitude),
                                  'phone': appState.phone,
                                  'price': appState.costoServicio,
                                  'distance': appState.distance,
                                  'duration': appState.duration
                                });
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
                'tripID': {'isAskingService': false}
              });
            },
          )),
        );
      },
    );
  }
}

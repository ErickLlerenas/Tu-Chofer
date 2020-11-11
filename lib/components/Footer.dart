import 'package:chofer/screens/origin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:chofer/screens/destination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return DraggableScrollableSheet(
        expand: true,
        maxChildSize: 0.385,
        initialChildSize: 0.385,
        minChildSize: 0.385,
        builder: (context, controller) {
          return Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Origin()));
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
                              builder: (context) => Destination()));
                    },
                    leading: Icon(Icons.location_on, color: Colors.red[400]),
                    title: Text("Destino"),
                    subtitle: Text('${appState.destinationController.text}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  !appState.isLoadingPrices
                      ? LinearProgressIndicator()
                      : ListTile(
                          leading: Icon(
                            Icons.attach_money,
                            color: Colors.teal[400],
                          ),
                          title: Text("Precio: \$${appState.precio}"),
                          subtitle: Text(
                            "Distancia: ${appState.distance}\nDuración: ${appState.duration}",
                          ),
                          trailing: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                              color: Colors.grey[800],
                              child: Text(
                                'Pide tu chofer',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _showDialog(appState.phone);
                                print(appState.origin);
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
                                  'price': appState.precio,
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

  void _showDialog(phone) {
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
              CircularProgressIndicator()
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
                  .updateData({'isAskingService': false});
            },
          )),
        );
      },
    );
  }
}

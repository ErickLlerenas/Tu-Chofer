import 'package:chofer/screens/user/driver-car-info.dart';
import 'package:chofer/screens/user/driver-info.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserAcceptedFooter extends StatefulWidget {
  UserAcceptedFooter();
  @override
  _UserAcceptedFooterState createState() => _UserAcceptedFooterState();
}

class _UserAcceptedFooterState extends State<UserAcceptedFooter> {
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
                  Text(
                    "Tu Chofer está en camino..",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverInfo(
                                  driverName: appState.driverName,
                                  driverPhone: appState.driverPhone,
                                  driverImage: appState.driverImage)));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(
                          appState.driverImage != null
                              ? appState.driverImage
                              : '',
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        );
                      }, height: 50, width: 50, fit: BoxFit.cover),
                    ),
                    title: Text("Tu Chofer"),
                    subtitle: Text(
                        'Nombre: ${appState.driverName}\nTeléfono: ${appState.driverPhone}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverCarInfo(
                                    driverCarImage: appState.driverCarImage,
                                    driverCarModel: appState.driverCarModel,
                                    driverCarName: appState.driverCarName,
                                    driverCarPlates: appState.driverCarPlates,
                                  )));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(
                          appState.driverCarImage != null
                              ? appState.driverCarImage
                              : '',
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        );
                      }, height: 50, width: 50, fit: BoxFit.cover),
                    ),
                    title: Text("Coche"),
                    subtitle: Text(
                        'Marca: ${appState.driverCarName}\nModelo: ${appState.driverCarModel}\nPlacas: ${appState.driverCarPlates}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    subtitle: ButtonTheme(
                      height: 45,
                      minWidth: 100,
                      child: FlatButton(
                        color: Colors.red[800],
                        child: Text(
                          'Cancelar servicio',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // appState.cancelService();
                          _showCancelServiceDialog(appState);
                        },
                      ),
                    ),
                  )
                ],
              ));
        });
  }

  Future<void> _showCancelServiceDialog(appState) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Cancelar servicio?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red[800],
              child: Text('Cancelar'),
              onPressed: () async {
                _showLoadingCancelDialog();
                await appState.cancelService();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadingCancelDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Cancelando..',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.normal,
                      fontSize: 20)),
              SizedBox(height: 10),
              Center(
                  child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red[800]),
              )),
            ],
          ),
        ));
      },
    );
  }
}

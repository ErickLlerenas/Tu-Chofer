import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/screens/driver-request-screen1.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverRequestPending extends StatefulWidget {
  @override
  _DriverRequestPendingState createState() => _DriverRequestPendingState();
}

class _DriverRequestPendingState extends State<DriverRequestPending> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: Container(
          padding: EdgeInsets.all(50),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/pending.png',
                height: 300,
              ),
              Text('Pendiente...',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text(
                'Espera a que Tu Chofer acepte tu solicitud',
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 40,
              ),
              FlatButton(
                height: 45,
                color: Colors.red,
                onPressed: () {
                  _showCancelAlert(appState);
                },
                child: Text('Cancelar solicitud',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ));
  }

  void _showCancelAlert(AppState appState) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("¿Cancelar solicitud?", textAlign: TextAlign.center),
          content: Container(
              height: 110,
              child: Column(children: [
                Text(
                    "Si quieres volver a mandar una solicitud podrás hacerlo después.",
                    textAlign: TextAlign.center),
                SizedBox(height: 15),
                FlatButton(
                  color: Colors.red,
                  child: Text("Sí, cancelar",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    appState.cancelDriverRequest();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DriverRequestScreen1()));
                  },
                )
              ])),
        );
      },
    );
  }
}

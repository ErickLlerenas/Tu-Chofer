import 'package:chofer/states/app-state.dart';
import 'package:chofer/states/location-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnableLocation extends StatefulWidget {
  @override
  _EnableLocationState createState() => _EnableLocationState();
}

class _EnableLocationState extends State<EnableLocation> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locationState = Provider.of<LocationState>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(60),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset(
                  'assets/location.png',
                  height: 330,
                ),
                Text('Activa tu ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
                Text(
                  'Necesitamos saber dónde estás',
                  style: TextStyle(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    color: Colors.orange,
                    padding: EdgeInsets.all(16),
                    child:
                        Text('Activar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      locationState.askPermission(appState, context);
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }
}

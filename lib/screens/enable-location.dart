import 'package:chofer/states/app-state.dart';
import 'package:chofer/states/location-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(60),
            child: Column(
              children: <Widget>[
                SvgPicture.asset(
                  'assets/location.svg',
                  height: 300,
                ),
                Text('Activa tu ubicación',
                    style: TextStyle(
                        fontSize: 20,
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
                    color: Colors.deepPurpleAccent[400],
                    padding: EdgeInsets.all(16),
                    child:
                        Text('Activar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      locationState.askPermission(appState,context);
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }
}

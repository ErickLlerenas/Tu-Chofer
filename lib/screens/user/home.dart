import 'package:chofer/screens/user/user-map.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int carsMakerHackToRunOnce = 0;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    //This loads the car image marker only once. Other wise the app starts lagging
    if (carsMakerHackToRunOnce == 0) appState.getCarMarker(context);
    carsMakerHackToRunOnce++;

    return Scaffold(
        floatingActionButton: appState.destination != null
            ? Container()
            : FloatingActionButton(
                onPressed: () {
                  appState.getCurrentLocation();
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.my_location, color: Colors.grey[700])),
        key: scaffoldKey,
        drawer: MyDrawer(),
        body: UserMap(scaffoldKey));
  }
}

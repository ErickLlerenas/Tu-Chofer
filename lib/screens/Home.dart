import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/screens/map.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        floatingActionButton: appState.destination != null
            ? Container()
            : FloatingActionButton(
                onPressed: () {
                  appState.currentLocation();
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.my_location, color: Colors.grey[700])),
        key: scaffoldKey,
        drawer: CustomDrawer(),
        body: Map(scaffoldKey));
  }
}

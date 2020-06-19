import 'package:chofer/screens/Home.dart';
import 'package:chofer/screens/history.dart';
import 'package:chofer/screens/mapa-chofer.dart';
import 'package:chofer/screens/mi-perfil.dart';
import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent),
            accountName: Text("${loginState.name}"),
            accountEmail: Text("${loginState.phone}"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "E",
                style: TextStyle(fontSize: 40.0, color: Colors.grey[600]),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Mapa'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mi perfil'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
             Navigator.pop(context);
              Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MiPerfil()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Historial()));
            },
          ),
          ListTile(
            leading: Icon(Icons.local_taxi),
            title: Text('Quiero ser chofer'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(Icons.my_location),
            title: Text('Mapa Chofer'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MapaChofer()));
            },
          ),
        ],
      ),
    );
  }
}

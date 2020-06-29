import 'package:chofer/screens/Home.dart';
import 'package:chofer/screens/driver-request-screen1.dart';
import 'package:chofer/screens/earnings-and-payments.dart';
import 'package:chofer/screens/history.dart';
import 'package:chofer/screens/driver-map.dart';
import 'package:chofer/screens/profile.dart';
import 'package:chofer/screens/terms-and-conditions.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.grey[800]),
            accountName: Text("${appState.name}"),
            accountEmail: Text("${appState.phone}"),
            currentAccountPicture: appState.image == null &&
                    appState.downloadURL == null
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${appState.name[0]}",
                      style: TextStyle(fontSize: 40.0, color: Colors.grey[600]),
                    ),
                  )
                : appState.image != null && appState.downloadURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Image.file(appState.image,
                            height: 50, width: 50, fit: BoxFit.cover),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Image.network(appState.downloadURL,
                            height: 50, width: 50, fit: BoxFit.cover),
                      ),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Mapa'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mi perfil'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => History()));
            },
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: ListTile(
              leading: Icon(Icons.local_taxi, color: Colors.grey[800]),
              title: Text(
                'Quiero ser chofer',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: Icon(Icons.navigate_next, color: Colors.grey[800]),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverRequestScreen1()));
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: ListTile(
              leading: Icon(Icons.my_location, color: Colors.grey[800]),
              title: Text(
                'Mapa Chofer',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: Icon(Icons.navigate_next, color: Colors.grey[800]),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DriverMap()));
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: ListTile(
              leading: Icon(Icons.attach_money, color: Colors.grey[800]),
              title: Text(
                'Ganancias y pagos',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: Icon(Icons.navigate_next, color: Colors.grey[800]),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EarningsAndPayments()));
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Terminos y condiciones'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TermsAndConditions()));
            },
          ),
        ],
      ),
    );
  }
}

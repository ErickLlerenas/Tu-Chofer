import 'package:chofer/screens/Home.dart';
import 'package:chofer/screens/driver-request-pending.dart';
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
            decoration: BoxDecoration(color: Colors.black87),
            accountName: Text("${appState.name}"),
            accountEmail: Text(
              "(${appState.phone[0]}${appState.phone[1]}${appState.phone[2]})-${appState.phone[3]}${appState.phone[4]}${appState.phone[5]}-${appState.phone[6]}${appState.phone[7]}${appState.phone[8]}${appState.phone[9]}",
            ),
            currentAccountPicture: appState.downloadURL.isEmpty
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${appState.name[0]}",
                      style: TextStyle(fontSize: 40.0, color: Colors.grey[600]),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.network(appState.downloadURL, loadingBuilder:
                        (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.orange),
                      );
                    }, height: 50, width: 50, fit: BoxFit.cover),
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
          appState.userIsDriver
              ? Container()
              : ListTile(
                  leading: Icon(Icons.local_taxi),
                  title: Text('Quiero ser chofer'),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    appState.userWantsToBeDriver
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverRequestPending()))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverRequestScreen1()));
                  },
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
          !appState.userIsDriver ? Container() : Divider(),
          !appState.userIsDriver
              ? Container()
              : ListTile(
                  leading: Icon(Icons.my_location, color: Colors.orange),
                  title: Text(
                    'Mapa Chofer',
                    style: TextStyle(color: Colors.orange),
                  ),
                  trailing: Icon(Icons.navigate_next, color: Colors.orange),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DriverMap()));
                  },
                ),
          !appState.userIsDriver
              ? Container()
              : ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.orange),
                  title: Text(
                    'Ganancias y pagos',
                    style: TextStyle(color: Colors.orange),
                  ),
                  trailing: Icon(Icons.navigate_next, color: Colors.orange),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EarningsAndPayments()));
                  },
                ),
        ],
      ),
    );
  }
}

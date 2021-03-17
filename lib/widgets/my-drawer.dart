import 'package:chofer/screens/user/home.dart';
import 'package:chofer/screens/driver/driver-messages.dart';
import 'package:chofer/screens/driver/driver-request-pending.dart';
import 'package:chofer/screens/driver/driver-request-screen1.dart';
import 'package:chofer/screens/driver/driver-earnings.dart';
// import 'package:chofer/screens/user/user-card-payment.dart';
import 'package:chofer/screens/user/user-history.dart';
import 'package:chofer/screens/user/user-messages.dart';
import 'package:chofer/screens/driver/driver-map.dart';
import 'package:chofer/screens/user/user-profile.dart';
import 'package:chofer/screens/user/user-terms-and-conditions.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Drawer(
      child: ListView(
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
            title: Text('Perfil'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserProfile()));
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.credit_card),
          //   title: Text('Pago con tarjeta'),
          //   trailing: Icon(Icons.navigate_next),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pop(context);

          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => UserCardPayment()));
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserHistory()));
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Mensajes'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserMessages()));
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
            title: Text('Términos y condiciones'),
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
          Divider(),
          !appState.userIsDriver
              ? Container()
              : ListTile(
                  leading: Icon(Icons.local_taxi, color: Colors.orange),
                  title: Text(
                    'Mapa',
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
                    'Ganancias',
                    style: TextStyle(color: Colors.orange),
                  ),
                  trailing: Icon(Icons.navigate_next, color: Colors.orange),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DriverEarnings()));
                  },
                ),
          !appState.userIsDriver
              ? Container()
              : ListTile(
                  leading: Icon(Icons.message, color: Colors.orange),
                  title:
                      Text('Mensajes', style: TextStyle(color: Colors.orange)),
                  trailing: Icon(Icons.navigate_next, color: Colors.orange),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DriverMessages()));
                  },
                ),
          !appState.userIsDriver ? Container() : Divider(),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.red[700]),
            title: Text('Emergencia', style: TextStyle(color: Colors.red[700])),
            trailing: Icon(Icons.navigate_next, color: Colors.red[700]),
            onTap: () async {
              Navigator.pop(context);
              if (await canLaunch('tel:911')) {
                await launch('tel:911');
              }
            },
          ),
        ],
      ),
    );
  }
}

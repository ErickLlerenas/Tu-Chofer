import 'package:chofer/screens/Origen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:chofer/screens/destino.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return DraggableScrollableSheet(
        expand: true,
        maxChildSize: 0.375,
        initialChildSize: 0.375,
        minChildSize: 0.375,
        builder: (context, controller) {
          return Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Origen()));
                    },
                    leading: Icon(Icons.location_on,color:Colors.blue[400]),
                    title: Text("Origen"),
                    subtitle: Text('${appState.locationController.text}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Destino()));
                    },
                    leading: Icon(Icons.location_on,color: Colors.red[400]),
                    title: Text("Destino"),
                    subtitle: Text('${appState.destinationController.text}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                      leading: Icon(Icons.attach_money,color: Colors.teal[400],),
                      title: Text(
                        "Precio \$55",
                      ),
                      trailing: ButtonTheme(
                        height: 50,
                        minWidth: 150,
                        child: FlatButton(
                          color: Colors.teal[400],
                          child: Text(
                            'Pide tu chofer',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {},
                        ),
                      ))
                ],
              ));
        });
  }
}

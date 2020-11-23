import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final history = [];
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: history.length != 0
            ? Center(
                child: SingleChildScrollView(
                child: Column(
                    children: appState.userHistory.map((history) {
                  return ListTile(
                    title: Text(
                        "Origen: ${history['origin']}\nDestino: ${history['destination']}"),
                    leading: Icon(Icons.date_range_outlined),
                    subtitle: Text('Costo: \$${history['cost']}'),
                  );
                }).toList()),
              ))
            : Container(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/empty.png',
                      height: 300,
                    ),
                    Text('Sin historial',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    Text(
                      'No haz realizado ningún viaje',
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
  }
}

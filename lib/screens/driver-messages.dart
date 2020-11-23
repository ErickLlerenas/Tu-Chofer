import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';

class DriverMessages extends StatefulWidget {
  @override
  _DriverMessagesState createState() => _DriverMessagesState();
}

class _DriverMessagesState extends State<DriverMessages> {
  final history = [];
  @override
  Widget build(BuildContext context) {
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
                  children: <Widget>[
                    ListTile(
                      title: Text('Lunes 15 de Junio del 2020'),
                      leading: Icon(Icons.date_range),
                      subtitle: Text('\$55'),
                      trailing: Icon(Icons.attach_money),
                    )
                  ],
                ),
              ))
            : Container(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/empty.png',
                      height: 300,
                    ),
                    Text('Sin mensajes',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    Text(
                      'No hay ningún mensaje',
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
  }
}

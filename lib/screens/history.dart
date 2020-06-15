import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';

class Historial extends StatefulWidget{
  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Center(
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
        )
      )
    );
  }
}
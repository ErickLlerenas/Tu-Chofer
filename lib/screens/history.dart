import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Historial extends StatefulWidget{
  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {

  final history = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      drawer: CustomDrawer(),
      body: history.length!=0?  Center(
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
      ):Container(
        padding: EdgeInsets.all(50),
        child: Column(
        children: <Widget>[
          SvgPicture.asset(
                'assets/empty.svg',
                height: 300,
              ),
          Text('Vacío',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
            Text(
              'No haz realizado ningún viaje',
              style: TextStyle(color: Colors.grey[700]),textAlign: TextAlign.center,
            ),
        ],
      ),
      )
    );
  }
}
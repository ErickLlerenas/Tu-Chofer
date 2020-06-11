import 'package:flutter/material.dart';
import 'package:chofer/components/from-input.dart';
import 'package:chofer/components/to-input.dart';

class Viaje extends StatefulWidget {
  @override
  _ViajeState createState() => _ViajeState();
}

class _ViajeState extends State<Viaje> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Row(
          children: <Widget>[Text('Tu viaje')],
        ),
      ),
      body: Stack(
        children: <Widget>[
          FromInput(),
          ToInput(),
        ],
      ),
    );
  }
}

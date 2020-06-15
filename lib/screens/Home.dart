import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';
import 'package:chofer/screens/Map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Map());
  }
}

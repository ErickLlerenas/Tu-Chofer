import 'package:flutter/material.dart';

class DriverCarInfo extends StatefulWidget {
  final String driverCarName;
  final String driverCarModel;
  final String driverCarImage;
  final String driverCarPlates;

  DriverCarInfo(
      {this.driverCarPlates,
      this.driverCarImage,
      this.driverCarName,
      this.driverCarModel});
  @override
  _DriverCarInfoState createState() => _DriverCarInfoState();
}

class _DriverCarInfoState extends State<DriverCarInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 35),
                      Text('Tu Chofer',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(250),
                              child: Image.network(widget.driverCarImage,
                                  height: 250, width: 250, fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(30),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Marca: ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.driverCarName,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Modelo: ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.driverCarModel,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Placas: ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.driverCarPlates,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }
}

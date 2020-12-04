import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfo extends StatefulWidget {
  final String driverPhone;
  final String driverImage;
  final String driverName;

  DriverInfo({this.driverPhone, this.driverImage, this.driverName});
  @override
  _DriverInfoState createState() => _DriverInfoState();
}

class _DriverInfoState extends State<DriverInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Tu Chofer',
            style: TextStyle(color: Colors.grey[700]),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 35),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(250),
                              child: Image.network(widget.driverImage,
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
                                'Nombre: ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.driverName,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Teléfono: ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "(${widget.driverPhone[0]}${widget.driverPhone[1]}${widget.driverPhone[2]})-${widget.driverPhone[3]}${widget.driverPhone[4]}${widget.driverPhone[5]}-${widget.driverPhone[6]}${widget.driverPhone[7]}${widget.driverPhone[8]}${widget.driverPhone[9]}",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FlatButton(
                                color: Colors.teal,
                                height: 45,
                                child: Text(
                                  'Llamar',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (await canLaunch(
                                      "tel:${widget.driverPhone}")) {
                                    await launch("tel:${widget.driverPhone}");
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }
}

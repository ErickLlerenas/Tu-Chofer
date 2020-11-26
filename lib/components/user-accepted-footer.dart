import 'package:chofer/screens/driver-car-info.dart';
import 'package:chofer/screens/driver-info.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAcceptedFooter extends StatefulWidget {
  final String driverImage;
  final String driverName;
  final String driverCarImage;
  final String driverCarName;
  final String driverCarPlates;
  final String driverPhone;
  final String driverCarModel;
  UserAcceptedFooter(
      {this.driverCarImage,
      this.driverCarName,
      this.driverCarPlates,
      this.driverImage,
      this.driverName,
      this.driverPhone,
      this.driverCarModel});
  @override
  _UserAcceptedFooterState createState() => _UserAcceptedFooterState();
}

class _UserAcceptedFooterState extends State<UserAcceptedFooter> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        maxChildSize: 0.5,
        initialChildSize: 0.5,
        minChildSize: 0.5,
        builder: (context, controller) {
          return Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  Text(
                    "Tu Chofer está en camino...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverInfo(
                                  driverName: widget.driverName,
                                  driverPhone: widget.driverPhone,
                                  driverImage: widget.driverImage)));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(widget.driverImage, loadingBuilder:
                          (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        );
                      }, height: 50, width: 50, fit: BoxFit.cover),
                    ),
                    title: Text("Tu Chofer"),
                    subtitle: Text('${widget.driverName}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverCarInfo(
                                    driverCarImage: widget.driverCarImage,
                                    driverCarModel: widget.driverCarModel,
                                    driverCarName: widget.driverCarName,
                                    driverCarPlates: widget.driverCarPlates,
                                  )));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(widget.driverCarImage,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        );
                      }, height: 50, width: 50, fit: BoxFit.cover),
                    ),
                    title: Text("Coche"),
                    subtitle: Text(
                        'Marca: ${widget.driverCarName}\nModel:${widget.driverCarModel}\nPlacas: ${widget.driverCarPlates}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () async {
                      if (await canLaunch("tel:${widget.driverPhone}")) {
                        await launch("tel:${widget.driverPhone}");
                      }
                    },
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.phone, color: Colors.white)),
                    title: Text("Teléfono"),
                    subtitle: Text('${widget.driverPhone}'),
                  ),
                  ListTile(
                    subtitle: ButtonTheme(
                      height: 45,
                      minWidth: 100,
                      child: FlatButton(
                        color: Colors.red,
                        child: Text(
                          'Cancelar chofer',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}

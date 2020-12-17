import 'package:chofer/screens/driver/driver-earnings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverStartedFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String duration;
  final String distance;
  final String driverPhone;
  final String userPhone;
  final String userName;
  DriverStartedFooter(
      {this.destination,
      this.origin,
      this.distance,
      this.driverPhone,
      this.duration,
      this.userPhone,
      this.userName,
      this.price});
  @override
  _DriverStartedFooterState createState() => _DriverStartedFooterState();
}

class _DriverStartedFooterState extends State<DriverStartedFooter> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        maxChildSize: 0.825,
        initialChildSize: 0.825,
        minChildSize: 0.115,
        builder: (BuildContext context, controller) {
          return Container(
              color: Colors.black54,
              child: ListView(
                controller: controller,
                children: <Widget>[
                  Icon(Icons.drag_handle, color: Colors.white),
                  Text(
                    "Servicio iniciado",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blue),
                    title: Text("${widget.origin}",
                        style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.red),
                    title: Text("${widget.destination}",
                        style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: Colors.teal[400],
                    ),
                    title: Text(
                      "\$${widget.price} pesos",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.local_taxi,
                      color: Colors.orange,
                    ),
                    title: Text(
                      "${widget.distance}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.timer,
                      color: Colors.pink,
                    ),
                    title: Text(
                      "${widget.duration}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: InkWell(
                      onTap: () async {
                        if (await canLaunch("tel: ${widget.userPhone}")) {
                          await launch("tel: ${widget.userPhone}");
                        }
                      },
                      child: Icon(
                        Icons.phone,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      "${widget.userPhone}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    title: Text(
                      "${widget.userName}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  !loading
                      ? ListTile(
                          title: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                                color: Colors.red,
                                child: Text("Finalizar Servicio",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  _finishService();
                                }),
                          ),
                        )
                      : ListTile(
                          title: LinearProgressIndicator(
                            minHeight: 50,
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                ],
              ));
        });
  }

  Future _finishService() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance
        .collection('Drivers')
        .document(widget.driverPhone)
        .get()
        .then((driver) async {
      if (driver.exists) {
        await Firestore.instance
            .collection('Users')
            .document(widget.userPhone)
            .get()
            .then((user) async {
          if (user.exists) {
            List driverHistory = []..addAll(driver['history']);
            List userhistory = []..addAll(user['history']);
            int driverIndex = driverHistory.length;
            int userIndex = userhistory.length;

            userhistory.add({
              'date': new DateTime.now(),
              'destination': widget.destination,
              'cost': widget.price,
              'origin': widget.origin,
              'payed': false,
              'index': userIndex,
              'driverIndex': driverIndex,
              'driverPhone': widget.driverPhone,
              'driverName': driver['name']
            });

            driverHistory.add({
              'date': new DateTime.now(),
              'destination': widget.destination,
              'cost': widget.price,
              'origin': widget.origin,
              'userName': widget.userName,
              'userPhone': widget.userPhone,
              'payed': false,
              'index': driverIndex,
              'userIndex': userIndex
            });

            await Firestore.instance
                .collection('Users')
                .document(widget.userPhone)
                .updateData({
              'history': userhistory,
              'tripID': {'isAskingService': false, 'driversList': []}
            });

            await Firestore.instance
                .collection('Drivers')
                .document(widget.driverPhone)
                .updateData({
              'history': driverHistory,
              'tripID': {
                'userID': '',
                'serviceAccepted': false,
                'serviceStarted': false,
                'serviceFinished': true
              }
            }).then((_) {
              setState(() {
                loading = false;
              });
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DriverEarnings()));
            });
          }
        });
      }
    });
  }
}

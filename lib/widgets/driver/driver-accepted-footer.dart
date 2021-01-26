import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverAcceptedFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String duration;
  final String distance;
  final String driverPhone;
  final String userPhone;
  final String userName;
  final Function driverCancelService;
  final Function startService;
  final bool userIsAskingService;
  final LatLng userDestination;
  final LatLng userOrigin;
  DriverAcceptedFooter(
      {this.origin,
      this.destination,
      this.price,
      this.duration,
      this.distance,
      this.driverPhone,
      this.driverCancelService,
      this.userName,
      this.userPhone,
      this.userIsAskingService,
      this.startService,
      this.userDestination,
      this.userOrigin});
  @override
  _DriverAcceptedFooterState createState() => _DriverAcceptedFooterState();
}

class _DriverAcceptedFooterState extends State<DriverAcceptedFooter> {
  bool canceling = false;
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
                    widget.userIsAskingService
                        ? "Servicio aceptado"
                        : "Servicio cancelado",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  widget.userIsAskingService
                      ? InkWell(
                          onTap: () async {
                            String googleUrl =
                                'https://www.google.com/maps/search/?api=1&query=${widget.userOrigin.latitude},${widget.userOrigin.longitude}';
                            if (await canLaunch(googleUrl)) {
                              await launch(googleUrl);
                            }
                          },
                          child: ListTile(
                            leading:
                                Icon(Icons.location_on, color: Colors.blue),
                            title: Text("${widget.origin}",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      : Container(),
                  widget.userIsAskingService
                      ? InkWell(
                          onTap: () async {
                            String googleUrl =
                                'https://www.google.com/maps/search/?api=1&query=${widget.userDestination.latitude},${widget.userDestination.longitude}';
                            if (await canLaunch(googleUrl)) {
                              await launch(googleUrl);
                            }
                          },
                          child: ListTile(
                            leading: Icon(Icons.location_on, color: Colors.red),
                            title: Text("${widget.destination}",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      : Container(),
                  widget.userIsAskingService
                      ? ListTile(
                          leading: Icon(
                            Icons.attach_money,
                            color: Colors.teal[400],
                          ),
                          title: Text(
                            "\$${widget.price} pesos",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(),
                  widget.userIsAskingService
                      ? ListTile(
                          leading: Icon(
                            Icons.local_taxi,
                            color: Colors.orange,
                          ),
                          title: Text(
                            "${widget.distance}",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(),
                  // widget.userIsAskingService
                  //     ? ListTile(
                  //         leading: Icon(
                  //           Icons.timer,
                  //           color: Colors.pink,
                  //         ),
                  //         title: Text(
                  //           "${widget.duration}",
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       )
                  //     : Container(),
                  widget.userIsAskingService
                      ? InkWell(
                          onTap: () async {
                            if (await canLaunch("tel: ${widget.userPhone}")) {
                              await launch("tel: ${widget.userPhone}");
                            }
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.phone,
                              color: Colors.green,
                            ),
                            title: Text(
                              "${widget.userPhone}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Container(),
                  widget.userIsAskingService
                      ? ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          title: Text(
                            "${widget.userName}",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(),
                  !widget.userIsAskingService
                      ? Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            "El usuario ${widget.userName} ha cancelado el servicio.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : Container(),
                  !widget.userIsAskingService
                      ? SizedBox(height: 30)
                      : Container(),
                  !widget.userIsAskingService
                      ? Icon(
                          Icons.error,
                          color: Colors.orange,
                          size: 200,
                        )
                      : Container(),
                  !widget.userIsAskingService
                      ? SizedBox(height: 30)
                      : Container(),
                  !widget.userIsAskingService && !canceling
                      ? ListTile(
                          title: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                                color: Colors.orange,
                                child: Text("Ok, regresar",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  canceling = true;
                                  setState(() {});
                                  await _cancelService();
                                  await widget.driverCancelService();
                                }),
                          ),
                        )
                      : canceling
                          ? LinearProgressIndicator()
                          : ListTile(
                              title: ButtonTheme(
                                height: 45,
                                minWidth: 100,
                                child: FlatButton(
                                    color: Colors.orange,
                                    child: Text("Cliente a bordo",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      _startService();
                                    }),
                              ),
                            )
                ],
              ));
        });
  }

  Future _cancelService() async {
    await Firestore.instance
        .collection('Drivers')
        .document(widget.driverPhone)
        .updateData({
      'tripID': {
        'userID': '',
        'serviceAccepted': false,
        'serviceStarted': false,
        'serviceFinished': false
      }
    });
  }

  Future _startService() async {
    widget.startService();
    await Firestore.instance
        .collection('Drivers')
        .document(widget.driverPhone)
        .updateData({
      'tripID': {
        'serviceAccepted': true,
        'userID': widget.userPhone,
        'serviceStarted': true,
        'serviceFinished': false
      }
    });
  }
}

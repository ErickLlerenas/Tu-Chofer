import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final bool driverIsInsideCircle;
  final bool userIsAskingService;
  DriverAcceptedFooter(
      {this.origin,
      this.destination,
      this.price,
      this.duration,
      this.distance,
      this.driverPhone,
      this.driverCancelService,
      this.driverIsInsideCircle,
      this.userName,
      this.userPhone,
      this.userIsAskingService,
      this.startService});
  @override
  _DriverAcceptedFooterState createState() => _DriverAcceptedFooterState();
}

class _DriverAcceptedFooterState extends State<DriverAcceptedFooter> {
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
                      ? ListTile(
                          leading: Icon(Icons.location_on, color: Colors.blue),
                          title: Text("${widget.origin}",
                              style: TextStyle(color: Colors.white)),
                        )
                      : Container(),
                  widget.userIsAskingService
                      ? ListTile(
                          leading: Icon(Icons.location_on, color: Colors.red),
                          title: Text("${widget.destination}",
                              style: TextStyle(color: Colors.white)),
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
                  widget.userIsAskingService
                      ? ListTile(
                          leading: Icon(
                            Icons.timer,
                            color: Colors.pink,
                          ),
                          title: Text(
                            "${widget.duration}",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(),
                  !widget.userIsAskingService
                      ? Container(
                          margin: EdgeInsets.all(20),
                          child: Text(
                              'El usuario ${widget.userName} ha cancelado la solicitud, puedes cancelar que aceptaste tu solicutid para buscar más usuarios o puedes esperar un poco a ver si vuelve a pedir solicutud.',
                              textAlign: TextAlign.justify,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        )
                      : Container(),
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
                  !widget.driverIsInsideCircle
                      ? ListTile(
                          title: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                                color: Colors.red,
                                child: Text("Cancelar servicio",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  _showCancelServiceDialog();
                                }),
                          ),
                        )
                      : ListTile(
                          title: ButtonTheme(
                            height: 45,
                            minWidth: 100,
                            child: FlatButton(
                                color: Colors.orange,
                                child: Text("Iniciar servicio",
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

  Future<void> _showCancelServiceDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Cancelar servicio?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red[800],
              child: Text('Cancelar'),
              onPressed: () async {
                Navigator.of(context).pop();
                _showLoadingCancelDialog();
                _cancelService();
                widget.driverCancelService();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _showLoadingCancelDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Cancelando..',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.normal,
                      fontSize: 20)),
              SizedBox(height: 10),
              Center(
                  child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red[800]),
              )),
            ],
          ),
        ));
      },
    );
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

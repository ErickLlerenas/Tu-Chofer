import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChoferFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String distance;
  final String duration;
  final String phone;
  ChoferFooter({this.origin,this.destination,this.price,this.distance,this.duration,this.phone});
  @override
  _ChoferFooterState createState() => _ChoferFooterState();
}

class _ChoferFooterState extends State<ChoferFooter> {

  int _time = 10;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void startTimer() {
  const oneSec = const Duration(seconds: 1);
  Timer.periodic(
    oneSec,
    (Timer timer) => setState(
      () {
        if (_time < 1) {
          timer.cancel();
        } else {
          _time = _time - 1;
        }
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {

    return _time == 0 ? Container(): DraggableScrollableSheet(
        expand: true,
        maxChildSize: 0.85,
        initialChildSize: 0.85,
        minChildSize: 0.85,
        builder: (context, controller) {
          return Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  Text('¡Nueva solicitud!',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color: Colors.grey[700],fontWeight: FontWeight.bold),),
                  Text('$_time',textAlign: TextAlign.center,style: TextStyle(fontSize: 40,color: Colors.grey[700],fontWeight: FontWeight.bold),),
                  ListTile(
                    
                    leading: Icon(Icons.location_on, color: Colors.blue[400]),
                    title: Text("Origen"),
                    subtitle: Text('${widget.origin}'),
                  ),
                  ListTile(
                   
                    leading: Icon(Icons.location_on, color: Colors.red[400]),
                    title: Text("Destino"),
                    subtitle: Text('${widget.destination}'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: Colors.teal[400],
                    ),
                    title: Text("Ganancia"),
                    subtitle: Text(
                      "\$${widget.price} pesos",
                    ),
                    
                    
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.local_taxi,
                      color: Colors.grey[700],
                    ),
                    title: Text("Distancia"),
                    subtitle: Text(
                      "${widget.duration}",
                    )),
                  ListTile(
                    leading: Icon(
                      Icons.timer,
                      color: Colors.grey[700],
                    ),
                    title: Text("Duración"),
                    subtitle: Text(
                      "${widget.duration}",
                    ),
                    
                    
                  ),
                  
                  ListTile(
                    title:ButtonTheme(
                      height: 50,
                      child: FlatButton(
                        color: Colors.teal,
                        child: Text(
                          'Aceptar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Firestore.instance.collection('Users').document('${widget.phone}').updateData({'serviceAccepted': true});
                        },
                      ),
                    )
                  )
                ],
              ));
        });
  }
}

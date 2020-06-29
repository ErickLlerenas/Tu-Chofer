import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String distance;
  final String duration;
  final String phone;
  DriverFooter({this.origin,this.destination,this.price,this.distance,this.duration,this.phone});
  @override
  _DriverFooterState createState() => _DriverFooterState();
}

class _DriverFooterState extends State<DriverFooter> {
  Timer _timer;
  int _time = 10;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    startTimer();
    playSound();
    super.initState();
  }
  void playSound()async{
    await audioPlayer.play('https://notificationsounds.com/soundfiles/08b255a5d42b89b0585260b6f2360bdd/file-sounds-1137-eventually.mp3',isLocal: false);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
  const oneSec = const Duration(seconds: 1);
  _timer = Timer.periodic(
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
 void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:  Text("Validando...",textAlign: TextAlign.center,style: TextStyle(color:Colors.grey[700],fontSize: 20,fontWeight: FontWeight.bold),),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
            ],
          )
          
        );
      },
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
                          setState(() {
                            _time = 0;
                          });
                          Firestore.instance.collection('Users').document('${widget.phone}').updateData({'serviceAccepted': true});
                          _showDialog();

                        },
                      ),
                    )
                  )
                ],
              ));
        });
  }
}

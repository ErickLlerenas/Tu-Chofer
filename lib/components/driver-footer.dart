import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class DriverFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String distance;
  final String duration;
  final String phone;
  DriverFooter(
      {this.origin,
      this.destination,
      this.price,
      this.distance,
      this.duration,
      this.phone});
  @override
  _DriverFooterState createState() => _DriverFooterState();
}

class _DriverFooterState extends State<DriverFooter> {
  Timer _timer;
  int _time = 10;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    startTimer();
    playSound();
    super.initState();
  }

  void playSound() {
    assetsAudioPlayer.open(Audio("assets/tone.mp3"));
  }

  void stopSound() {
    assetsAudioPlayer.stop();
  }

  @override
  void dispose() {
    _timer.cancel();
    stopSound();
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Validando...",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return _time == 0
        ? Container()
        : DraggableScrollableSheet(
            expand: true,
            maxChildSize: 0.8,
            initialChildSize: 0.8,
            minChildSize: 0.8,
            builder: (context, controller) {
              return Container(
                  color: Colors.white,
                  child: ListView(
                    children: <Widget>[
                      Text(
                        '¡Nueva solicitud!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.location_on, color: Colors.blue[400]),
                        title: Text("Origen"),
                        subtitle: Text('${widget.origin}'),
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.location_on, color: Colors.red[400]),
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
                          title: ButtonTheme(
                        height: 50,
                        child: FlatButton(
                          color: Colors.orange,
                          child: Text(
                            'Aceptar',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            stopSound();
                            setState(() {
                              _time = 0;
                            });
                            Firestore.instance
                                .collection('Drivers')
                                .document('${appState.phone}')
                                .updateData({
                              'tripID': {
                                'userID': widget.phone,
                                'accepted': true,
                                'driversOrderList': []
                              }
                            });
                            _showDialog();
                          },
                        ),
                      ))
                    ],
                  ));
            });
  }
}

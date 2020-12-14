import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class DriverRequestFooter extends StatefulWidget {
  final String origin;
  final String destination;
  final int price;
  final String distance;
  final String duration;
  final String phone;
  final Function acceptService;
  final Function disposeUserService;
  DriverRequestFooter(
      {this.origin,
      this.destination,
      this.price,
      this.distance,
      this.duration,
      this.phone,
      this.acceptService,
      this.disposeUserService});
  @override
  _DriverRequestFooterState createState() => _DriverRequestFooterState();
}

class _DriverRequestFooterState extends State<DriverRequestFooter> {
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
            widget.disposeUserService();
          } else {
            _time = _time - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _time == 0
        ? Container()
        : DraggableScrollableSheet(
            maxChildSize: 0.7,
            initialChildSize: 0.7,
            minChildSize: 0.7,
            builder: (context, controller) {
              return Container(
                  color: Colors.white,
                  child: ListView(
                    children: <Widget>[
                      Text(
                        '¡Viaje encontrado!',
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
                        title: Text("Costo"),
                        subtitle: Text(
                          "\$${widget.price} pesos",
                        ),
                      ),
                      ListTile(
                          leading: Icon(
                            Icons.local_taxi,
                            color: Colors.orange,
                          ),
                          title: Text("Distancia"),
                          subtitle: Text(
                            "${widget.distance}",
                          )),
                      ListTile(
                        leading: Icon(
                          Icons.timer,
                          color: Colors.pink,
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
                              widget.acceptService();
                            });
                          },
                        ),
                      ))
                    ],
                  ));
            });
  }
}

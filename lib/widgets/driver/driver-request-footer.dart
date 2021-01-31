import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = "AIzaSyB6TIHbzMpZYQs8VwYMuUZaMuk4VaKudeY";

class DriverRequestFooter extends StatefulWidget {
  final String phone;
  final Function acceptService;
  final Function closeAlert;
  final Function openAlert;
  final LatLng userOrigin;
  final LatLng driverOrigin;

  DriverRequestFooter(
      {this.phone,
      this.acceptService,
      this.openAlert,
      this.closeAlert,
      this.userOrigin,
      this.driverOrigin});
  @override
  _DriverRequestFooterState createState() => _DriverRequestFooterState();
}

class _DriverRequestFooterState extends State<DriverRequestFooter> {
  Timer _timer;
  int _time = 10;
  final assetsAudioPlayer = AssetsAudioPlayer();
  Color color = Colors.white;
  double margin = 20;
  bool hackAlert = false;
  double heigth = 2.4;
  Map answer;

  void animateAlert() {
    hackAlert = !hackAlert;
    setState(() {
      if (hackAlert) {
        margin = 15;
        heigth = 2.3;
        color = Colors.white70;
      } else {
        margin = 20;
        heigth = 2.4;
        color = Colors.white;
      }
    });
  }

  @override
  void initState() {
    widget.openAlert();
    Future.delayed(Duration(seconds: 0), () async {
      answer = await getRouteDistanceAndDuration(
          widget.driverOrigin, widget.userOrigin);
    });

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
    widget.closeAlert();
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
          animateAlert();

          if (_time < 1) {
            widget.closeAlert();
            timer.cancel();
          } else {
            _time = _time - 1;
          }
        },
      ),
    );
  }

  Future<Map> getRouteDistanceAndDuration(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    Map answer = {
      'route': values["routes"][0]["overview_polyline"]["points"],
      'distanceText': values["routes"][0]["legs"][0]["distance"]["text"],
      'durationText': values["routes"][0]["legs"][0]["duration"]["text"],
      'distanceValue': values["routes"][0]["legs"][0]["distance"]["value"],
      'durationValue': values["routes"][0]["legs"][0]["duration"]["value"]
    };
    return answer;
  }

  @override
  Widget build(BuildContext context) {
    return _time == 0
        ? Container()
        : Center(
            child: InkWell(
              onTap: () {
                stopSound();
                setState(() {
                  _time = 0;
                  if (answer['route'] != null)
                    widget.acceptService(answer['route'], Colors.blue);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: AnimatedContainer(
                  margin: EdgeInsets.all(margin),
                  width: MediaQuery.of(context).size.height / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  curve: Curves.bounceOut,
                  duration: Duration(milliseconds: 900),
                  child: Container(
                      child: ListView(
                    children: <Widget>[
                      Text(
                        '¿Aceptar viaje?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 5.0,
                        percent: _time / 10,
                        center: Text(
                          '$_time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.orange[300],
                              fontWeight: FontWeight.bold),
                        ),
                        progressColor: Colors.orange[300],
                      ),
                      SizedBox(height: 20),
                      answer != null
                          ? Text(
                              'Estás a ${(answer['durationValue'] / 60).toInt()} minutos\n${answer['distanceText']}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                              textAlign: TextAlign.center)
                          : Text('Calculando...',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                              textAlign: TextAlign.center)
                    ],
                  )),
                ),
              ),
            ),
          );
  }
}

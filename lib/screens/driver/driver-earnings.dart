import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:path_provider/path_provider.dart';

class DriverEarnings extends StatefulWidget {
  @override
  _DriverEarningsState createState() => _DriverEarningsState();
}

class _DriverEarningsState extends State<DriverEarnings> {
  List driverHistory = [];
  bool isLoadingHistory = true;

  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<File> writePhone(String phoneNumber) async {
    final file = await _localFileNumber;
    return file.writeAsString('$phoneNumber');
  }

  Future<String> readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Future getUserHistory() async {
    await Firestore.instance
        .collection('Drivers')
        .document(await readPhoneNumber())
        .get()
        .then((user) {
      if (user.exists) {
        setState(() {
          driverHistory = user.data['history'];
          driverHistory = new List.from(driverHistory.reversed);
        });
      }
      setState(() {
        isLoadingHistory = false;
      });
    });
  }

  @override
  void initState() {
    getUserHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Ganancias", style: TextStyle(color: Colors.grey[700])),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: MyDrawer(),
        body: isLoadingHistory
            ? Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
              ))
            : driverHistory.length != 0
                ? SingleChildScrollView(
                    child: Column(
                        children: driverHistory.map((history) {
                      // Convert the date to a decent string
                      String date = history['date']
                          .toDate()
                          .toString()
                          .substring(0,
                              history['date'].toDate().toString().length - 7);

                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        child: Card(
                          color: Colors.teal[50],
                          child: Column(
                            children: [
                              ListTile(
                                title: Text("Ganancia:"),
                                leading: Icon(Icons.attach_money,
                                    color: Colors.teal),
                                subtitle: Text("\$${history['gain']} pesos"),
                              ),
                              ListTile(
                                title: Text("Fecha y hora:"),
                                leading: Icon(Icons.date_range,
                                    color: Colors.black87),
                                subtitle: Text(date),
                              ),
                              ListTile(
                                title: Text("Origen:"),
                                leading:
                                    Icon(Icons.location_on, color: Colors.blue),
                                subtitle: Text(history['origin']),
                              ),
                              ListTile(
                                title: Text("Destino:"),
                                leading:
                                    Icon(Icons.location_on, color: Colors.red),
                                subtitle: Text(history['destination']),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
                  )
                : Container(
                    padding: EdgeInsets.all(50),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/empty.png',
                          height: 300,
                        ),
                        Text('Sin historial',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700])),
                        Text(
                          'No haz realizado ningún viaje',
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ));
  }
}

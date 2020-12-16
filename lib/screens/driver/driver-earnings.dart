import 'dart:async';
import 'package:chofer/screens/driver/driver-earnings-payment.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverEarnings extends StatefulWidget {
  get userPhone => null;

  @override
  _DriverEarningsState createState() => _DriverEarningsState();
}

class _DriverEarningsState extends State<DriverEarnings> {
  List driverHistory = [];
  bool isLoadingHistory = true;
  String driverPhone;

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
    driverPhone = await readPhoneNumber();
    await Firestore.instance
        .collection('Drivers')
        .document(driverPhone)
        .get()
        .then((user) {
      if (user.exists) {
        driverHistory = user.data['history'];
        driverHistory = new List.from(driverHistory.reversed);
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

  Future<Null> _onRefresh() async {
    Completer<Null> completer = new Completer<Null>();
    getUserHistory();
    completer.complete();
    return completer.future;
  }

  Future makePayment(int driverIndex, int userIndex, String userPhone) async {
    setState(() {
      Map selectedHistory = driverHistory[driverIndex];
      selectedHistory['payed'] = true;
      driverHistory[driverIndex] = selectedHistory;
    });
    await Firestore.instance
        .collection('Drivers')
        .document(driverPhone)
        .updateData({
      'history': new List.from(driverHistory.reversed),
      'tripID': {
        'userID': '',
        'serviceAccepted': false,
        'serviceStarted': false,
        'serviceFinished': false
      }
    });

    await Firestore.instance
        .collection('Users')
        .document(userPhone)
        .get()
        .then((user) async {
      if (user.exists) {
        List userHistory = user['history'];
        Map selectedHistory = userHistory[userIndex];
        selectedHistory['payed'] = true;
        userHistory[userIndex] = selectedHistory;

        await Firestore.instance
            .collection('Users')
            .document(userPhone)
            .updateData({'history': userHistory});
      }
    });
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
        body: RefreshIndicator(
          child: isLoadingHistory
              ? Center(
                  child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                ))
              : driverHistory.length != 0
                  ? ListView.builder(
                      itemCount: driverHistory.length,
                      itemBuilder: _itemBuilder,
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
                    ),
          onRefresh: _onRefresh,
        ));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    // Convert the date to a decent string
    String date = driverHistory[index]['date'].toDate().toString().substring(
        0, driverHistory[index]['date'].toDate().toString().length - 7);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DriverEarningsPayment(
                    date: date,
                    index: index,
                    driverPhone: driverPhone,
                    makePayment: makePayment,
                    userPhone: driverHistory[index]['userPhone'],
                    userName: driverHistory[index]['userName'],
                    userIndex: driverHistory[index]['userIndex'],
                    payed: driverHistory[index]['payed'],
                    cost: driverHistory[index]['cost'],
                    destination: driverHistory[index]['destination'],
                    origin: driverHistory[index]['origin'])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        child: Card(
          color: driverHistory[index]['payed']
              ? Colors.orange[100]
              : Colors.grey[200],
          child: Column(
            children: [
              ListTile(
                title: Text("Costo:"),
                leading: Icon(Icons.attach_money, color: Colors.teal),
                subtitle: Text("\$${driverHistory[index]['cost']} pesos"),
              ),
              ListTile(
                title: Text("Fecha y hora:"),
                leading: Icon(Icons.date_range, color: Colors.black87),
                subtitle: Text(date),
              ),
              ListTile(
                title: Text("Origen:"),
                leading: Icon(Icons.location_on, color: Colors.blue),
                subtitle: Text(driverHistory[index]['origin']),
              ),
              ListTile(
                title: Text("Destino:"),
                leading: Icon(Icons.location_on, color: Colors.red),
                subtitle: Text(driverHistory[index]['destination']),
              ),
              ListTile(
                leading: InkWell(
                  onTap: () async {
                    if (await canLaunch(
                        "tel: ${driverHistory[index]['userPhone']}")) {
                      await launch("tel: ${driverHistory[index]['userPhone']}");
                    }
                  },
                  child: Icon(
                    Icons.phone,
                    color: Colors.green,
                  ),
                ),
                title: Text('Teléfono:'),
                subtitle: Text("${driverHistory[index]['userPhone']}"),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                title: Text('Nombre:'),
                subtitle: Text("${driverHistory[index]['userName']}"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

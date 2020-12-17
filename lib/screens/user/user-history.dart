import 'dart:async';
import 'dart:io';
import 'package:chofer/screens/user/user-payment.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistoryState createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  List userHistory = [];
  bool isLoadingHistory = true;

  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<String> _readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Future<Null> _onRefresh() async {
    Completer<Null> completer = new Completer<Null>();
    _getUserHistory();
    completer.complete();
    return completer.future;
  }

  Future _getUserHistory() async {
    await Firestore.instance
        .collection('Users')
        .document(await _readPhoneNumber())
        .get()
        .then((user) {
      if (user.exists) {
        setState(() {
          userHistory = user.data['history'];
          userHistory = new List.from(userHistory.reversed);
        });
      }
      setState(() {
        isLoadingHistory = false;
      });
    });
  }

  @override
  void initState() {
    _getUserHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Historial", style: TextStyle(color: Colors.grey[700])),
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
              : userHistory.length != 0
                  ? ListView.builder(
                      itemCount: userHistory.length,
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
    String date = userHistory[index]['date'].toDate().toString().substring(
        0, userHistory[index]['date'].toDate().toString().length - 7);

    Future makePayment() async {
      //Pendiente para la siguiente actualización.
      print('PAGADOOOOO');
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserPayment(
                    date: date,
                    index: index,
                    driverName: userHistory[index]['driverName'],
                    makePayment: makePayment,
                    userPhone: userHistory[index]['userPhone'],
                    payed: userHistory[index]['payed'],
                    cost: userHistory[index]['cost'],
                    destination: userHistory[index]['destination'],
                    origin: userHistory[index]['origin'])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        child: Card(
          color: userHistory[index]['payed']
              ? Colors.orange[100]
              : Colors.grey[200],
          child: Column(
            children: [
              ListTile(
                title: Text("Costo:"),
                leading: Icon(Icons.attach_money, color: Colors.teal),
                subtitle: Text("\$${userHistory[index]['cost']} pesos"),
              ),
              ListTile(
                title: Text("Fecha y hora:"),
                leading: Icon(Icons.date_range, color: Colors.black87),
                subtitle: Text(date),
              ),
              ListTile(
                title: Text("Origen:"),
                leading: Icon(Icons.location_on, color: Colors.blue),
                subtitle: Text(userHistory[index]['origin']),
              ),
              ListTile(
                title: Text("Destino:"),
                leading: Icon(Icons.location_on, color: Colors.red),
                subtitle: Text(userHistory[index]['destination']),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                title: Text('Chofer:'),
                subtitle: Text(userHistory[index]['driverName']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

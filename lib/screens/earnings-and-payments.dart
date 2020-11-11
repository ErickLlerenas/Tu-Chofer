import 'package:flutter/material.dart';
import 'package:chofer/components/custom-drawer.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class EarningsAndPayments extends StatefulWidget {
  @override
  _EarningsAndPaymentsState createState() => _EarningsAndPaymentsState();
}

class _EarningsAndPaymentsState extends State<EarningsAndPayments> {
  final history = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: history.length != 0
            ? Center(
                child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Lunes 15 de Junio del 2020'),
                      leading: Icon(Icons.date_range),
                      subtitle: Text('\$55'),
                      trailing: Icon(Icons.attach_money),
                    )
                  ],
                ),
              ))
            : Container(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/empty.png',
                      height: 300,
                    ),
                    Text('Sin ganancias',
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

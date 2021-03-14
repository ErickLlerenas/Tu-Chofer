import 'package:chofer/data/cards.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class UserCardPayment extends StatefulWidget {
  @override
  _UserCardPaymentState createState() => _UserCardPaymentState();
}

class _UserCardPaymentState extends State<UserCardPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pago con tarjeta",
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: Icon(Icons.add),
          onPressed: () {
            print('Add btn');
          }),
      body: tarjetas.length == 0
          ? Center(
              child: Container(
              padding: EdgeInsets.all(50),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/credit-card.png',
                    height: 300,
                  ),
                  Text('Sin tarjetas',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700])),
                  Text(
                    'No haz agregado ninguna tarjeta',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ))
          : ListView(
              children: tarjetas
                  .map((tarjeta) => CreditCardWidget(
                        cardNumber: tarjeta.cardNumber,
                        expiryDate: tarjeta.expiracyDate,
                        cardHolderName: tarjeta.cardHolderName,
                        cvvCode: tarjeta.cvv,
                        showBackView: false,
                      ))
                  .toList(),
            ),
    );
  }
}

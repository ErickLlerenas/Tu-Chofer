import 'package:flutter/material.dart';

class UserPayment extends StatefulWidget {
  final String date;
  final int index;
  final String userPhone;
  final bool payed;
  final int cost;
  final String destination;
  final String origin;
  final String driverName;
  final Function makePayment;

  UserPayment(
      {this.cost,
      this.driverName,
      this.makePayment,
      this.date,
      this.destination,
      this.index,
      this.origin,
      this.payed,
      this.userPhone});

  @override
  _UserPaymentState createState() => _UserPaymentState();
}

class _UserPaymentState extends State<UserPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.payed ? Colors.orange : Colors.grey,
        title: Text(widget.payed ? 'Pagado' : 'Sin pagar'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Costo:"),
            leading: Icon(Icons.attach_money, color: Colors.teal),
            subtitle: Text("\$${widget.cost} pesos"),
          ),
          ListTile(
            title: Text("Fecha y hora:"),
            leading: Icon(Icons.date_range, color: Colors.black87),
            subtitle: Text(widget.date),
          ),
          ListTile(
            title: Text("Origen:"),
            leading: Icon(Icons.location_on, color: Colors.blue),
            subtitle: Text(widget.origin),
          ),
          ListTile(
              title: Text("Destino:"),
              leading: Icon(Icons.location_on, color: Colors.red),
              subtitle: Text(widget.destination)),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.grey,
            ),
            title: Text('Chofer:'),
            subtitle: Text(widget.driverName),
          ),
          SizedBox(height: 30),
          !widget.payed
              ? Column(
                  children: [
                    Text(
                      'El pago con tarjeta estará disponible en futuras actualizaciones...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    ListTile(
                        title: FlatButton(
                      height: 45,
                      color: Colors.orange,
                      child: Text("Realizar pago con tarjeta",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        // await widget.makePayment();
                      },
                    )),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}

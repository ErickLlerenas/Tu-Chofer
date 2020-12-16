import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverEarningsPayment extends StatefulWidget {
  final int cost;
  final String date;
  final String origin;
  final String destination;
  final bool payed;
  final int index;
  final int userIndex;
  final String userPhone;
  final String driverPhone;
  final Function makePayment;
  final String userName;
  DriverEarningsPayment(
      {this.cost,
      this.date,
      this.destination,
      this.origin,
      this.payed,
      this.index,
      this.userIndex,
      this.userPhone,
      this.driverPhone,
      this.makePayment,
      this.userName});
  @override
  _DriverEarningsPaymentState createState() => _DriverEarningsPaymentState();
}

class _DriverEarningsPaymentState extends State<DriverEarningsPayment> {
  bool loading = false;
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
            leading: InkWell(
              onTap: () async {
                if (await canLaunch("tel: ${widget.userPhone}")) {
                  await launch("tel: ${widget.userPhone}");
                }
              },
              child: Icon(
                Icons.phone,
                color: Colors.green,
              ),
            ),
            title: Text('Teléfono:'),
            subtitle: Text("${widget.userPhone}"),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.grey,
            ),
            title: Text('Nombre:'),
            subtitle: Text("${widget.userName}"),
          ),
          SizedBox(height: 30),
          !widget.payed
              ? !loading
                  ? ListTile(
                      title: FlatButton(
                      height: 45,
                      color: Colors.orange,
                      child: Text("Realizar pago en efectivo",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        _showShouldPayDialog();
                      },
                    ))
                  : LinearProgressIndicator()
              : Container()
        ],
      ),
    );
  }

  _showShouldPayDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Marcar como pagado?',
            textAlign: TextAlign.center,
          ),
          content: Text('El usuario ha realizado su pago en efectivo.'),
          actions: <Widget>[
            FlatButton(
              color: Colors.orange,
              child: Text(
                'Sí',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                await widget.makePayment(
                    widget.index, widget.userIndex, widget.userPhone);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

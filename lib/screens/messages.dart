import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('Users')
                .document(appState.phone)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) return Container();
              List userMessages = [];

              snapshot.data['messages'].forEach((message) {
                userMessages.add(message);
              });
              return SingleChildScrollView(
                child: Column(
                    children: userMessages.map((msg) {
                  return msg['name'] != "Base"
                      ? Container(
                          width: 250,
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(30),
                            ),
                            color: Colors.orange[200],
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${msg['message']}",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        )
                      : Container(
                          width: 250,
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(30),
                            ),
                            color: Colors.orange[50],
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${msg['name']}",
                                  style: TextStyle(fontSize: 18)),
                              Text("${msg['message']}",
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        );
                }).toList()),
              );
            }));
  }
}
/*
 : Container(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/empty.png',
                      height: 300,
                    ),
                    Text('Sin mensajes',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    Text(
                      'No hay ningún mensaje',
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
 */

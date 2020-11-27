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
  ScrollController _userScrollController = new ScrollController();
  TextEditingController _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    _userScrollController.animateTo(0.0,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Mensajes",
            style: TextStyle(color: Colors.grey[700]),
          ),
          backgroundColor: Colors.grey[100],
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
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: SingleChildScrollView(
                        controller: _userScrollController,
                        reverse: true,
                        child: Column(
                            children: userMessages.map((msg) {
                          var time;
                          if (msg['time'] != null) {
                            time =
                                DateTime.parse(msg['time'].toDate().toString());
                            print(time.hour);
                            print(time.minute);
                          }

                          return msg['name'] != "Tu Chofer"
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: new Container(
                                      margin: EdgeInsets.only(
                                          top: 5,
                                          left: 100,
                                          right: 15,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(40),
                                        ),
                                        color: Colors.orange[100],
                                      ),
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${msg['message']}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          time != null
                                              ? Text(
                                                  "${time.hour}:${time.minute}",
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                )
                                              : Container()
                                        ],
                                      )),
                                )
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 5,
                                        right: 100,
                                        left: 15,
                                        bottom: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(40),
                                        topRight: Radius.circular(15),
                                      ),
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${msg['name']}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.orange)),
                                        Text("${msg['message']}",
                                            style: TextStyle(fontSize: 16))
                                      ],
                                    ),
                                  ),
                                );
                        }).toList()),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: Container(
                              color: Colors.white,
                              child: TextFormField(
                                onChanged: (String text) {
                                  setState(() {});
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: TextStyle(fontSize: 18),
                                cursorColor: Colors.orange,
                                cursorHeight: 22,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    hintText: "Escribe un mensaje..."),
                                controller: _messageController,
                              ),
                            ),
                          ),
                          _messageController.text.isNotEmpty
                              ? Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        color: Colors.orange,
                                        icon: Icon(Icons.send),
                                        onPressed: () async {
                                          await Firestore.instance
                                              .collection('Users')
                                              .document(appState.phone)
                                              .get()
                                              .then((user) async {
                                            List temp = [];
                                            temp = user['messages'];
                                            temp.add({
                                              'name': appState.name,
                                              'message':
                                                  _messageController.text,
                                              'time': new DateTime.now()
                                            });
                                            await Firestore.instance
                                                .collection('Users')
                                                .document(appState.phone)
                                                .updateData({'messages': temp});
                                          });

                                          setState(() {
                                            _messageController.text = "";
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(child: Container())
                        ],
                      ),
                    )
                  ],
                ),
              );
            }));
  }
}

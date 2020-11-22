import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/components/custom-drawer.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.nameController = TextEditingController(text: appState.name);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 35),
                      Text('Mi perfil',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: appState.image == null &&
                                appState.downloadURL.isEmpty
                            ? Stack(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      "${appState.name[0]}",
                                      style: TextStyle(
                                          fontSize: 80.0,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                                  FloatingActionButton(
                                      backgroundColor: Colors.orange,
                                      onPressed: () => appState.getImage(),
                                      child: Icon(Icons.add_a_photo))
                                ],
                              )
                            : appState.image != null &&
                                    appState.downloadURL != null
                                ? Stack(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: Image.file(appState.image,
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover),
                                      ),
                                      FloatingActionButton(
                                          backgroundColor: Colors.orange,
                                          onPressed: () => appState.getImage(),
                                          child: Icon(Icons.add_a_photo)),
                                    ],
                                  )
                                : Stack(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: Image.network(
                                            appState.downloadURL,
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover),
                                      ),
                                      FloatingActionButton(
                                          backgroundColor: Colors.orange,
                                          onPressed: () => appState.getImage(),
                                          child: Icon(Icons.add_a_photo)),
                                    ],
                                  ),
                      ),
                      Container(
                        padding: EdgeInsets.all(30),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "(${appState.phone[0]}${appState.phone[1]}${appState.phone[2]})-${appState.phone[3]}${appState.phone[4]}${appState.phone[5]}-${appState.phone[6]}${appState.phone[7]}${appState.phone[8]}${appState.phone[9]}",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: appState.nameController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200])),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300])),
                                    hintText: "¿Cómo te llamas?"),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ButtonTheme(
                                height: 45,
                                minWidth: double.infinity,
                                child: FlatButton(
                                  color: Colors.black87,
                                  child: Text(
                                    'Guardar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (appState
                                            .nameController.text.isNotEmpty &&
                                        appState.nameController.text !=
                                            appState.name) {
                                      appState.saveName(
                                          appState.phone,
                                          appState.nameController.text,
                                          context);
                                    }
                                    appState.saveUserProfilePicture(
                                        context, appState.phone);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }
}

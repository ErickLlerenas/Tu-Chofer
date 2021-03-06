import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/widgets/my-drawer.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.nameController = TextEditingController(text: appState.name);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Perfil', style: TextStyle(color: Colors.grey[700])),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: MyDrawer(),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 35),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: appState.image == null &&
                                appState.downloadURL.isEmpty
                            ? Stack(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 125,
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
                                            BorderRadius.circular(250),
                                        child: Image.file(appState.image,
                                            height: 250,
                                            width: 250,
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
                                            BorderRadius.circular(250),
                                        child: Image.network(
                                            appState.downloadURL,
                                            height: 250,
                                            width: 250,
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

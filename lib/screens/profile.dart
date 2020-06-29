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
                                appState.downloadURL == null
                            ? Stack(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      "Foto de perfil",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                                  FloatingActionButton(
                                      backgroundColor: Colors.grey[800],
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
                                          backgroundColor:
                                              Colors.grey[800],
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
                                          backgroundColor:
                                              Colors.grey[800],
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
                                  color: Colors.grey[800],
                                  child: Text(
                                    'Guardar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (appState.nameController.text.length!=0) {
                                      print(appState.nameController.text);
                                      appState.saveName(
                                          appState.phone,
                                          appState.nameController.text);
                                      appState.savePicture(
                                          context, appState.phone);
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  )
                ));
  }
}

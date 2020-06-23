import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/components/custom-drawer.dart';
import 'package:provider/provider.dart';

class MiPerfil extends StatefulWidget {
  @override
  _MiPerfilState createState() => _MiPerfilState();
}

class _MiPerfilState extends State<MiPerfil> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: CustomDrawer(),
        body: Center(
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
                child: _image == null
                    ? Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white,
                            child: Text(
                              "Foto de perfil",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.grey[600]),
                            ),
                          ),
                          FloatingActionButton(
                              backgroundColor: Colors.deepPurpleAccent,
                              onPressed: () => getImage(),
                              child: Icon(Icons.add_a_photo))
                        ],
                      )
                    : Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.file(_image,
                                height: 200, width: 200, fit: BoxFit.cover),
                          ),
                          FloatingActionButton(
                              onPressed: () => getImage(),
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
                        initialValue: loginState.name,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[200])),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300])),
                            hintText: "¿Cómo te llamas?"),
                      ),
                SizedBox(
                  height: 20,
                ),
                      ButtonTheme(
                height: 45,
                minWidth: double.infinity,
                child: FlatButton(
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              )
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ));
  }
}

import 'dart:io';
import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChoferRegistro extends StatefulWidget {
  @override
  _ChoferRegistroState createState() => _ChoferRegistroState();
}

class _ChoferRegistroState extends State<ChoferRegistro> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if(pickedFile!=null)
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Form(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             
              Text('Regístrate',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text(
                'Registro para ser chofer',
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: _image == null
                    ? Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white,
                            child: Text(
                              "Foto del coche",
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
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Marca del coche"),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Modelo del coche"),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Solicitar permiso"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {},
                  color: Colors.deepPurpleAccent,
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}

import 'package:chofer/components/custom-drawer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverRequestScreen2 extends StatefulWidget {
  @override
  _DriverRequestScreen2State createState() => _DriverRequestScreen2State();
}

class _DriverRequestScreen2State extends State<DriverRequestScreen2> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.carNameController = TextEditingController(text: appState.carName);
    appState.carModelController =
        TextEditingController(text: appState.carModel);
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
                'Danos información sobre tu coche',
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: appState.carImage == null
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
                              onPressed: () => appState.getCarImage(),
                              child: Icon(Icons.add_a_photo))
                        ],
                      )
                    : Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.file(appState.carImage,
                                height: 200, width: 200, fit: BoxFit.cover),
                          ),
                          FloatingActionButton(
                              onPressed: () => appState.getCarImage(),
                              child: Icon(Icons.add_a_photo)),
                        ],
                      ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: appState.carNameController,
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
                controller: appState.carModelController,
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
                  onPressed: () {
                    print(appState.carModelController.text);
                    if (appState.carNameController.text.length != 0 &&
                        appState.carModelController.text.length != 0) {
                      appState.saveDriverDataRequest(
                          appState.phone,
                          appState.name,
                          appState.address,
                          appState.carNameController.text,
                          appState.carModelController.text,
                          context);
                      appState.savePicture(context, appState.phone);
                      appState.saveCarPicture(context, appState.phone);
                    }
                  },
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

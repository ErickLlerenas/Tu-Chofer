import 'package:chofer/widgets/my-drawer.dart';
import 'package:chofer/screens/driver/driver-request-screen2.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverRequestScreen1 extends StatefulWidget {
  @override
  _DriverRequestScreen1State createState() => _DriverRequestScreen1State();
}

class _DriverRequestScreen1State extends State<DriverRequestScreen1> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.registerNameController =
        TextEditingController(text: appState.tempName);
    appState.addressController = TextEditingController(text: appState.address);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      drawer: MyDrawer(),
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
                'Necesitamos información sobre ti',
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: appState.image == null && appState.downloadURL.isEmpty
                    ? Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 125,
                            backgroundColor: Colors.white,
                            child: Text(
                              "Foto de perfil",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.grey[600]),
                            ),
                          ),
                          FloatingActionButton(
                              backgroundColor: Colors.orange,
                              onPressed: () => appState.getImage(),
                              child: Icon(Icons.add_a_photo))
                        ],
                      )
                    : appState.image != null
                        ? Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(250),
                                child: Image.file(appState.image,
                                    height: 250, width: 250, fit: BoxFit.cover),
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
                                borderRadius: BorderRadius.circular(250),
                                child: Image.network(appState.downloadURL,
                                    height: 250, width: 250, fit: BoxFit.cover),
                              ),
                              FloatingActionButton(
                                  backgroundColor: Colors.orange,
                                  onPressed: () => appState.getImage(),
                                  child: Icon(Icons.add_a_photo)),
                            ],
                          ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: appState.registerNameController,
                decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorStyle: TextStyle(color: Colors.orange),
                    errorText: !appState.validName
                        ? "Ingresa tu nombre completo"
                        : null,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Nombre completo"),
              ),
              TextFormField(
                controller: appState.addressController,
                decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorStyle: TextStyle(color: Colors.orange),
                    errorText:
                        !appState.validAddres ? "Ingresa tu domcilio" : null,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Domicilio"),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Continuar"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    appState.registerNameController.text.isEmpty
                        ? appState.validateNameInput(
                            false, appState.registerNameController.text)
                        : appState.validateNameInput(
                            true, appState.registerNameController.text);

                    appState.addressController.text.isEmpty
                        ? appState.validateAddresInput(
                            false, appState.addressController.text)
                        : appState.validateAddresInput(
                            true, appState.addressController.text);

                    if (appState.validName && appState.validAddres) {
                      if (appState.downloadURL.isNotEmpty ||
                          appState.image != null) {
                        appState.nextScreen(
                            appState.registerNameController.text,
                            appState.addressController.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverRequestScreen2()));
                      } else {
                        appState.showImageAlertDialog(
                            context, "Necesitas una foto de perfil.");
                      }
                    }
                  },
                  color: Colors.black87,
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}

import 'package:chofer/widgets/my-drawer.dart';
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
    appState.carPlatesController =
        TextEditingController(text: appState.carPlates);

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
                            radius: 125,
                            backgroundColor: Colors.white,
                            child: Text(
                              "Foto del coche",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.grey[600]),
                            ),
                          ),
                          FloatingActionButton(
                              backgroundColor: Colors.orange,
                              onPressed: () => appState.getCarImage(),
                              child: Icon(Icons.add_a_photo))
                        ],
                      )
                    : Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(250),
                            child: Image.file(appState.carImage,
                                height: 250, width: 250, fit: BoxFit.cover),
                          ),
                          FloatingActionButton(
                              backgroundColor: Colors.orange,
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
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorStyle: TextStyle(color: Colors.orange),
                    errorText: !appState.validCarName
                        ? "Ingresa la marca del coche"
                        : null,
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
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorStyle: TextStyle(color: Colors.orange),
                    errorText: !appState.validCarModel
                        ? "Ingresa el modelo del coche"
                        : null,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Modelo del coche"),
              ),
              TextFormField(
                controller: appState.carPlatesController,
                decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.orange)),
                    errorStyle: TextStyle(color: Colors.orange),
                    errorText: !appState.validCarPlates
                        ? "Ingresa las placas del coche"
                        : null,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Placas del coche"),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Solicitar permiso"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    appState.carNameController.text.isEmpty
                        ? appState.validateCarName(
                            false, appState.carNameController.text)
                        : appState.validateCarName(
                            true, appState.carNameController.text);

                    appState.carModelController.text.isEmpty
                        ? appState.validateCarModel(
                            false, appState.carModelController.text)
                        : appState.validateCarModel(
                            true, appState.carModelController.text);

                    appState.carPlatesController.text.isEmpty
                        ? appState.validateCarPlates(
                            false, appState.carPlatesController.text)
                        : appState.validateCarPlates(
                            true, appState.carPlatesController.text);

                    if (appState.validCarName &&
                        appState.validCarModel &&
                        appState.validCarPlates) {
                      if (appState.carImage != null) {
                        appState.saveDriverDataRequest(
                            appState.phone,
                            appState.name,
                            appState.address,
                            appState.carNameController.text,
                            appState.carModelController.text,
                            appState.carPlatesController.text,
                            context);
                      } else {
                        appState.imageAlert(
                            context, "Necesitas una foto de tu coche.");
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

import 'package:chofer/components/footer.dart';
import 'package:chofer/components/to-input.dart';
import 'package:chofer/components/user-accepted-footer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Map extends StatefulWidget {
  final scaffoldKey;
  Map(this.scaffoldKey);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  String driverCarName;
  String driverCarImage;
  String driverName;
  String driverCarModel;
  String driverImage;
  String driverPhone;
  String driverCarPlates;
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return appState.initialPosition == null
        ? Container(
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          )
        : StreamBuilder(
            stream: Firestore.instance.collection('Drivers').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Container();

              var cars = [];
              snapshot.data.documents.forEach((DocumentSnapshot document) {
                if (document['currentLocation'] != null &&
                    document['isActive']) {
                  cars.add({
                    'currentLocation': document['currentLocation'],
                    'currentLocationHeading': document['currentLocationHeading']
                  });
                }
                if (document['tripID'] != null) {
                  if (document['tripID']['userID'] == appState.phone) {
                    if (document['tripID']['accepted']) {
                      if (appState.hack == 0) {
                        if (appState.isAskingService) {
                          Navigator.pop(context);
                          appState.countHack();
                          driverCarName = document['carName'];
                          driverCarImage = document['car'];
                          driverImage = document['image'];
                          driverName = document['name'];
                          driverPhone = document['phone'];
                          driverCarPlates = document['carPlates'];
                          driverCarModel = document['carModel'];
                        }
                      }
                    }
                  }
                }
              });
              if (appState.destinationController.text.isEmpty) {
                appState.updateCarMarker(cars, appState, context);
              }

              return Stack(children: <Widget>[
                GoogleMap(
                    buildingsEnabled: true,
                    indoorViewEnabled: true,
                    initialCameraPosition: CameraPosition(
                        target: appState.initialPosition, zoom: 15),
                    onMapCreated: appState.onMapCreated,
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    polylines: appState.polyLines,
                    markers: appState.markers),
                appState.destinationController.text.isEmpty
                    ? ToInput()
                    : !appState.serviceAccepted
                        ? Footer()
                        : UserAcceptedFooter(
                            driverCarName: driverCarName,
                            driverCarImage: driverCarImage,
                            driverCarPlates: driverCarPlates,
                            driverImage: driverImage,
                            driverName: driverName,
                            driverPhone: driverPhone,
                            driverCarModel: driverCarModel,
                          ),
                Positioned(
                  left: 8,
                  top: 25,
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () =>
                        widget.scaffoldKey.currentState.openDrawer(),
                  ),
                ),
              ]);
            });
  }
}

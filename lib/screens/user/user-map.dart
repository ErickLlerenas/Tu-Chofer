import 'package:chofer/widgets/user/autocomplete-input.dart';
import 'package:chofer/widgets/user/user-accepted-footer.dart';
import 'package:chofer/widgets/user/user-request-footer.dart';
import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMap extends StatefulWidget {
  final scaffoldKey;
  UserMap(this.scaffoldKey);
  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      Provider.of<AppState>(context).getCarMarker(context);
      Provider.of<AppState>(context).getUserDataInCaseUserExitsTheApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return appState.initialPosition == null
        ? Container(
            alignment: Alignment.center,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  Text(
                    '\nCargando ubicación...',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          )
        : StreamBuilder(
            stream: Firestore.instance.collection('Drivers').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Container();

              appState.handleStream(snapshot, context);

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
                appState.destinationController.text.isEmpty &&
                        !appState.serviceAccepted
                    ? AutoCompleteInput()
                    : !appState.serviceAccepted && !appState.serviceFinished
                        ? UserRequestFooter()
                        : UserAcceptedFooter(),
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

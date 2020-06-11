import 'package:chofer/states/app-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FromInput extends StatefulWidget{
  @override
  _FromInputState createState() => _FromInputState();
}

class _FromInputState extends State<FromInput> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return (Positioned(
          top: 30.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 5,
                    spreadRadius: 0)
              ],
            ),
            child: TextField(
              cursorColor: Colors.black,
              controller: appState.locationController,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                // appState.sendRequest(value);
              },
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20, top:0),
                  width: 10,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.yellow[800],
                  ),
                ),
                hintText: "¿Dónde estás?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 0.0),
              ),
            ),
          ),
        ));
  }
}
import 'package:flutter/material.dart';
import 'package:chofer/screens/Viaje.dart';

class WhereToGoButton extends StatefulWidget{
  @override
  WhereToGoButtonState createState() => WhereToGoButtonState();
}

class WhereToGoButtonState extends State<WhereToGoButton> {
  @override
  Widget build(BuildContext context) {
    return (Positioned(
          top: 90.0,
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
              onTap: (){
                 Navigator.push(
                context, MaterialPageRoute(builder: (context) => Viaje()));
              },
              readOnly: true,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20, top:0),
                  width: 10,
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.yellow[800],
                  ),
                ),
                hintText: "¿A dónde quieres ir?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 0.0),
              ),
            ),
          ),
        ));
   
  }
}
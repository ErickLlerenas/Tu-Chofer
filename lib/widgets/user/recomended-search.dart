import 'package:chofer/states/app-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecomendedSearch extends StatefulWidget {
  final String phone;
  RecomendedSearch({this.phone});
  @override
  _RecomendedSearchState createState() => _RecomendedSearchState();
}

class _RecomendedSearchState extends State<RecomendedSearch> {
  String recomended;
  @override
  void initState() {
    Firestore.instance
        .collection('Users')
        .document(widget.phone)
        .get()
        .then((user) {
      if (user['history'] != null) {
        if (user['history'].length != 0) {
          setState(() {
            recomended = user['history'][(user['history'].length - 1)]
                    ['destination']
                .toString();
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return recomended == null
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 15),
            child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () {
                  appState.getCurrentLocationAndAnimateCamera();
                  appState.destinationController.text = recomended;
                  appState.sendRequest(recomended, context);
                },
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                minWidth: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 12,
                      child: Text(
                        "Sugerencia: $recomended",
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    ),
                    Expanded(
                        child: Icon(Icons.search, color: Colors.grey[700]),
                        flex: 1)
                  ],
                )));
  }
}

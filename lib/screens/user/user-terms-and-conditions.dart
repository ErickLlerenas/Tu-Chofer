import 'package:chofer/widgets/my-drawer.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Términos y condiciones",
            style: TextStyle(color: Colors.grey[700]),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.black),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Center(
              child: Container(
            margin: EdgeInsets.all(25),
            child: Column(
              children: <Widget>[
                Text(
                  "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 17, color: Colors.grey[800]),
                )
              ],
            ),
          )),
        ));
  }
}

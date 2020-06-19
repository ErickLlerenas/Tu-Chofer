import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/components/custom-drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';


class MiPerfil extends StatefulWidget{
  @override
  _MiPerfilState createState() => _MiPerfilState();
}

class _MiPerfilState extends State<MiPerfil> {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return Scaffold(
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
                  'assets/user.svg',
                  height: 150,
                  color: Colors.grey[700],
                ),
            Text(
          '${loginState.name}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.grey[700])
        ),
        Text('${loginState.phone}',style: TextStyle(color: Colors.grey[700])),
        SizedBox(
          height: 30,
        ),
        ButtonTheme(
          height: 45,
          minWidth: 125,
          child: FlatButton(
          color: Colors.teal[400],
          child: Text('Guardar',style: TextStyle(color:Colors.white),),
          onPressed: (){
            
          },
        ),
        )
          ],
        ),
      )
    );
  }
}
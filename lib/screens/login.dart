import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {

    final loginState = Provider.of<LoginState>(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/bg.svg',
                height: 300,
              ),
              Text('Hola',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
            Text(
              'Crea una nueva cuenta',
              style: TextStyle(color: Colors.grey[700]),textAlign: TextAlign.center,
            ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Ingresa tu nombre"),
                controller: loginState.nameController,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    hintText: "Número de teléfono"),
                controller: loginState.phoneController,
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Crear cuenta"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: ()async {
                    if(loginState.nameController.text != "" && loginState.phoneController.text !=""){
                    await loginState.loginUser(loginState.phoneController.text.trim(), context);                  
                    }
                  },
                  color: Colors.deepPurpleAccent,
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}

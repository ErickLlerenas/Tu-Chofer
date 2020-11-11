import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(40),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/bg.png',
                    height: 330,
                  ),
                  Text('Tu Chofer',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700])),
                  Text(
                    'Para iniciar crea una cuenta',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: Colors.deepPurpleAccent)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: Colors.deepPurpleAccent)),
                        errorStyle: TextStyle(color: Colors.deepPurpleAccent),
                        errorText: !loginState.validName
                            ? "Ingresa tu nombre completo"
                            : null,
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
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: Colors.deepPurpleAccent)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: Colors.deepPurpleAccent)),
                        errorStyle: TextStyle(color: Colors.deepPurpleAccent),
                        errorText: !loginState.validPhone
                            ? "Ingresa los 10 digitos de tu telefono"
                            : null,
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
                    child: !loginState.isLoading
                        ? FlatButton(
                            child: Text("Crear cuenta"),
                            textColor: Colors.white,
                            padding: EdgeInsets.all(16),
                            onPressed: () async {
                              loginState.nameController.text.isEmpty
                                  ? loginState.validateNameInput(false)
                                  : loginState.validateNameInput(true);

                              loginState.phoneController.text.trim().length ==
                                      10
                                  ? loginState.validatePhoneInput(true)
                                  : loginState.validatePhoneInput(false);

                              if (loginState.validName &&
                                  loginState.validPhone) {
                                await loginState.loginUser(
                                    loginState.phoneController.text.trim(),
                                    context);
                              }
                            },
                            color: Colors.deepPurpleAccent,
                          )
                        : LinearProgressIndicator(
                            minHeight: 50,
                            backgroundColor: Colors.deepPurple[50],
                            valueColor: AlwaysStoppedAnimation(
                                Colors.deepPurpleAccent)),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationCode extends StatefulWidget {
  @override
  _VerificationCodeState createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(50),
            child: Column(
              children: <Widget>[
                SizedBox(height: 40),
                Image.asset(
                  'assets/msg.png',
                  height: 300,
                ),
                Text('Verifica tu número',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
                Text(
                  'Escribe el código enviado a ${loginState.phoneController.text}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(
                  height: 20,
                ),
                PinCodeTextField(
                  errorAnimationController: loginState.errorController,
                  length: 6,
                  autoDisposeControllers: false,
                  obsecureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    inactiveFillColor: Colors.white,
                    inactiveColor: Colors.grey[700],
                    selectedFillColor: Colors.white,
                    selectedColor: Colors.orange,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.white,
                  enableActiveFill: true,
                  controller: loginState.codeController,
                  onCompleted: (value) {},
                  onChanged: (value) {
                    print(value);
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    return true;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '¿Te equivocaste de número? \nInténtalo de nuevo',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    color: Colors.orange,
                    padding: EdgeInsets.all(16),
                    child: Text('Verificar',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      loginState.verifyCode(
                          loginState.codeController.text, context);
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

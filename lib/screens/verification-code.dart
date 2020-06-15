import 'package:chofer/screens/enable-location.dart';
import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(50),
        child: Column(
          children: <Widget>[
            SvgPicture.asset(
              'assets/msg.svg',
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
              length: 6,
              autoDisposeControllers: false,
              obsecureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                inactiveFillColor: Colors.white,
                inactiveColor: Colors.grey[700],
                selectedFillColor: Colors.white,
                selectedColor: Colors.deepPurpleAccent,
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
              onCompleted: (value) {
                loginState.verifyCode(value,loginState.verificationID,context,loginState.auth);
              },
              onChanged: (value) {
                print(value);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
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
                color: Colors.teal[400],
                padding: EdgeInsets.all(16),
                child: Text('Verificar', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EnableLocation()));
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}

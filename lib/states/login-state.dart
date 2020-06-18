import 'dart:convert';

import 'package:chofer/screens/enable-location.dart';
import 'package:chofer/screens/login.dart';
import 'package:chofer/screens/verification-code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoginState with ChangeNotifier {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  String _phone;
  String verificationID;
  FirebaseAuth auth;
  bool isRegistred = true;

  get phoneController => _phoneController;
  get nameController => _nameController;
  get codeController => _codeController;
  get phone => _phone;

  LoginState() {
    getPhone();
  }

  Future getPhone() async {
    _phone = await readPhoneNumber();
    print(_phone);
    if(_phone!=null)
      isRegistred=true;
    else
      isRegistred=false;
    notifyListeners();
  }

  Future loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    auth = _auth;

    _auth.verifyPhoneNumber(
        phoneNumber: "+52" + phone,
        timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async {
          String credencial = credential.toString().replaceRange(0 , 12, '');
          credencial = credencial.substring(0,credencial.length-1);
          Map mapa = json.decode(credencial);
          codeController.text = mapa['zzb'];
          notifyListeners();
          AuthResult result = await _auth.signInWithCredential(credential);
          FirebaseUser user = result.user;
          if (user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EnableLocation()));
            writeCounter(phoneController.text.trim());  
          } else {
            print("Error");
          }
        },
        verificationFailed: (AuthException exception) {
          print("FAILED");
          print(exception.message);
          Navigator.push(context,
                MaterialPageRoute(builder: (context) => Login()));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationID = verificationId;
          Navigator.push(context,
                MaterialPageRoute(builder: (context) => VerificationCode()));
        },
        codeAutoRetrievalTimeout: (String id){
          verificationID = id;
        });
    notifyListeners();
  }

  Future verifyCode(String code, BuildContext context)async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationID, smsCode: code);
    AuthResult result = await auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
    
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => EnableLocation()));
      writeCounter(phoneController.text.trim());  
    } else {
      print("Error");
    }
  }

  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<File> writeCounter(String phone) async {
    final file = await _localFileNumber;
    return file.writeAsString('$phone');
  }

  Future<String> readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  notifyListeners();
}

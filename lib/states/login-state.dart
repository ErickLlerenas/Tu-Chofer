import 'package:chofer/screens/enable-location.dart';
import 'package:chofer/screens/verification-code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chofer/screens/Home.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoginState with ChangeNotifier {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  String _phone = "";
  String verificationID;
  FirebaseAuth auth;

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
    notifyListeners();
  }

  void pruebaXD() {}

  Future loginUser(String phone, BuildContext context) async {
    print(phone);
    FirebaseAuth _auth = FirebaseAuth.instance;
    auth = _auth;
    notifyListeners();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await _auth.signInWithCredential(credential);
          FirebaseUser user = result.user;
          if (user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EnableLocation()));
          } else {
            print("Error");
          }
        },
        verificationFailed: (AuthException exception) {
          print("FAILED");
          print(exception.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationID = verificationId;
          Navigator.push(context,
                MaterialPageRoute(builder: (context) => VerificationCode()));
        },
        codeAutoRetrievalTimeout: null);
    notifyListeners();
  }

  Future verifyCode(code,verificationId,context,_auth)async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: code);
    AuthResult result = await _auth.signInWithCredential(credential);

    FirebaseUser user = result.user;

    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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

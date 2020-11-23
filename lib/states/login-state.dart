import 'dart:async';
import 'dart:convert';
import 'package:chofer/screens/enable-location.dart';
import 'package:chofer/screens/login.dart';
import 'package:chofer/screens/verification-code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginState with ChangeNotifier {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  String _phone;
  String _name;
  String verificationID;
  FirebaseAuth auth;
  bool isRegistred = true;
  bool validName = true;
  bool validPhone = true;
  bool isLoading = false;
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  get phoneController => _phoneController;
  get nameController => _nameController;
  get codeController => _codeController;
  get phone => _phone;
  get name => _name;

  LoginState() {
    getPhoneNumber();
    getUserName();
  }

  //GETS THE PHONE NUMBER
  //CHECKS IF THERE IS A PHONE NUMBER ALREADY REGISTERED, SO THE USER SHOULDN'T LOGIN AGAIN
  Future getPhoneNumber() async {
    _phone = await readPhoneNumber();
    if (_phone.length == 0)
      isRegistred = false;
    else
      isRegistred = true;
    notifyListeners();
  }

  //GETS THE USER NAME
  Future getUserName() async {
    _name = await readName();
    notifyListeners();
  }

  // LOGINS THE USER WITH FIREBASE PHONE VERIFICATION
  Future loginUser(String phone, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    auth = FirebaseAuth.instance;
    auth.setLanguageCode('es');
    auth.verifyPhoneNumber(
        phoneNumber: "+52$phone",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await auth.signInWithCredential(credential);
          print("AUTOMATICALLY LOGED IN");
          if (result.user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EnableLocation()));
            writePhone(phoneController.text.trim());
            writeName(nameController.text);
            isLoading = false;
            await saveUserToFirebase(
                phoneController.text.trim(), nameController.text);
            notifyListeners();

            // IF GETS THE SMS CODE AUTOMATICALLY ,AUTO COMPLETE THE CODE ON VERIFY CODE SCREEN
            String credencial = credential.toString().replaceRange(0, 12, '');
            credencial = credencial.substring(0, credencial.length - 1);
            Map mapa = json.decode(credencial);
            codeController.text = mapa['zzb'];
            notifyListeners();
          }
        },
        verificationFailed: (AuthException exception) {
          print("FAILED: ${exception.message}");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationID = verificationId;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => VerificationCode()));
          isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String id) {
          verificationID = id;
        });
    notifyListeners();
  }

  // SAVE THE USER TO FIREBASE
  Future saveUserToFirebase(String id, String name) async {
    await Firestore.instance
        .collection('Users')
        .document(id)
        .get()
        .then((user) async {
      if (!user.exists) {
        await Firestore.instance.collection('Users').document(id).setData({
          'name': name,
          'isAskingService': false,
          'phone': id,
          'history': []
        });
        notifyListeners();
      }
    });
  }

  // VERIFYS THE CODE NUMBER SENT
  Future verifyCode(String code, BuildContext context) async {
    try {
      AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: verificationID, smsCode: code);
      AuthResult result = await auth.signInWithCredential(credential);
      FirebaseUser user = result.user;

      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EnableLocation()));
        writePhone(phoneController.text.trim());
        writeName(nameController.text);
        await saveUserToFirebase(
            phoneController.text.trim(), nameController.text);
      }
    } catch (error) {
      errorController.add(ErrorAnimationType.shake);
    }
  }

  void validateNameInput(bool isValid) {
    validName = isValid;
    notifyListeners();
  }

  void validatePhoneInput(bool isValid) {
    validPhone = isValid;
    notifyListeners();
  }

  // GET THE LOCAL PATH TO SAVE THE PHONE NUMBER
  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //GET THE LOCAL PATH WITH FILE TO SAVE THE PHONE NUMBER
  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  // WRITE THE PHONE NUMBER TO THE FILE
  Future<File> writePhone(String phoneNumber) async {
    final file = await _localFileNumber;
    return file.writeAsString('$phoneNumber');
  }

  // READ THE PHONE NUMBER FROM THE FILE
  Future<String> readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  // GET THE LOCAL PATH TO SAVE THE USER NAME
  Future<String> get _localPathName async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //GET THE LOCAL PATH WITH FILE TO SAVE THE USER NAME
  Future<File> get _localFileName async {
    final path = await _localPathName;
    return File('$path/login_name.txt');
  }

  // WRITE THE USER NAME TO THE FILE
  Future<File> writeName(String userName) async {
    final file = await _localFileName;
    return file.writeAsString('$userName');
  }

  // READ THE USER NAME FROM THE FILE
  Future<String> readName() async {
    try {
      final file = await _localFileName;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  notifyListeners();
}

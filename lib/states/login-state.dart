import 'dart:async';
import 'dart:convert';
import 'package:chofer/screens/login/enable-location.dart';
import 'package:chofer/screens/login/login.dart';
import 'package:chofer/screens/login/verification-code.dart';
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

  Future getPhoneNumber() async {
    _phone = await readPhoneNumber();
    if (_phone.length == 0)
      isRegistred = false;
    else
      isRegistred = true;
    notifyListeners();
  }

  Future getUserName() async {
    _name = await readName();
    notifyListeners();
  }

  Future loginUser(String phone, BuildContext context) async {
    isLoading = true;
    auth = FirebaseAuth.instance;
    auth.setLanguageCode('es');
    await auth.verifyPhoneNumber(
        phoneNumber: "+52$phone",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await auth.signInWithCredential(credential);
          if (result.user != null) {
            getCodeSentWhenAutoComplete(credential);
            await saveUserToFirebase(
                phoneController.text.trim(), nameController.text, context);
          }
        },
        verificationFailed: (AuthException exception) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationID = verificationId;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => VerificationCode()));
          isLoading = false;
        },
        codeAutoRetrievalTimeout: (String id) {
          verificationID = id;
        });
    notifyListeners();
  }

  Future saveUserToFirebase(
      String id, String name, BuildContext context) async {
    await Firestore.instance
        .collection('Users')
        .document(id)
        .get()
        .then((user) async {
      if (!user.exists) {
        await Firestore.instance.collection('Users').document(id).setData({
          'name': name,
          'phone': id,
          'history': [],
          'messages': [
            {
              'message':
                  '¡Hola ${name.split(' ')[0]}😄!  ¿Tienes alguna duda? Mándanos un mensaje y te responderemos en seguida...',
              'name': 'Tu Chofer'
            }
          ]
        }).then((value) {
          writePhone(phoneController.text.trim());
          writeName(nameController.text);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EnableLocation()));
          isLoading = false;
        });
      } else {
        writePhone(phoneController.text.trim());
        writeName(nameController.text);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EnableLocation()));
        isLoading = false;
      }
    });
    notifyListeners();
  }

  void getCodeSentWhenAutoComplete(credential) {
    String credencial = credential.toString().replaceRange(0, 12, '');
    credencial = credencial.substring(0, credencial.length - 1);
    Map mapa = json.decode(credencial);
    codeController.text = mapa['zzb'];
    notifyListeners();
  }

  Future verifyCode(String code, BuildContext context) async {
    try {
      AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: verificationID, smsCode: code);
      AuthResult result = await auth.signInWithCredential(credential);
      FirebaseUser user = result.user;

      if (user != null) {
        await saveUserToFirebase(
            phoneController.text.trim(), nameController.text, context);
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

  Future<String> get _localPathNumber async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileNumber async {
    final path = await _localPathNumber;
    return File('$path/login_number.txt');
  }

  Future<File> writePhone(String phoneNumber) async {
    final file = await _localFileNumber;
    return file.writeAsString('$phoneNumber');
  }

  Future<String> readPhoneNumber() async {
    try {
      final file = await _localFileNumber;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Future<String> get _localPathName async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileName async {
    final path = await _localPathName;
    return File('$path/login_name.txt');
  }

  Future<File> writeName(String userName) async {
    final file = await _localFileName;
    return file.writeAsString('$userName');
  }

  Future<String> readName() async {
    try {
      final file = await _localFileName;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }
}

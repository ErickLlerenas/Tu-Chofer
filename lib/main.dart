//import 'package:chofer/screens/login.dart';
import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/states/app-state.dart';
import 'package:chofer/screens/Home.dart';
import 'package:provider/provider.dart';

main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
  ChangeNotifierProvider.value(value: AppState()),
  ChangeNotifierProvider.value(value: LoginState())
],child: MyApp()));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Login()
      home: Home()
    );
  }
}
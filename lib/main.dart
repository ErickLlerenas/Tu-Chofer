import 'package:chofer/screens/enable-location.dart';
import 'package:chofer/screens/login.dart';
import 'package:chofer/states/login-state.dart';
import 'package:flutter/material.dart';
import 'package:chofer/states/app-state.dart';
import 'package:chofer/states/location-state.dart';
// import 'package:chofer/screens/Home.dart';
import 'package:provider/provider.dart';

main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
  ChangeNotifierProvider.value(value: AppState()),
  ChangeNotifierProvider.value(value: LoginState()),
  ChangeNotifierProvider.value(value: LocationState()),

],child: MyApp()));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginState.isRegistred ? EnableLocation():Login()
    );
  }
}
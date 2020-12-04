import 'package:flutter/material.dart';
import 'package:chofer/screens/login/enable-location.dart';
import 'package:chofer/screens/login/login.dart';
import 'package:chofer/screens/user/home.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chofer/states/app-state.dart';
import 'package:chofer/states/login-state.dart';
import 'package:chofer/states/location-state.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: AppState()),
    ChangeNotifierProvider.value(value: LoginState()),
    ChangeNotifierProvider.value(value: LocationState()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final loginState = Provider.of<LoginState>(context);
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
        title: 'Tu Chofer',
        debugShowCheckedModeBanner: false,
        home: loginState.isRegistred && appState.serviceEnabled
            ? Home()
            : loginState.isRegistred && !appState.serviceEnabled
                ? EnableLocation()
                : Login());
  }
}

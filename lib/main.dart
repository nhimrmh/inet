import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:inet/views/login_view.dart';
import 'package:overlay_support/overlay_support.dart';
import 'classes/dependency_injection.dart';
import 'classes/socket_service.dart';
//test
Injector injector;
final SocketService socketService = injector.get<SocketService>();

class AppInitializer {
  initialise(Injector injector) async {}
}

void main() async {
  DependencyInjection().initialise(Injector.getInjector());
  injector = Injector.getInjector();
  await AppInitializer().initialise(injector);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
  //connectAndListen1();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Socket IO',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 16, color: Colour("#051639"), fontWeight: FontWeight.w500),
            headline2: TextStyle(fontSize: 20, color: Colour("#051639"), fontWeight: FontWeight.w500),
            subtitle1: TextStyle(fontSize: 14, color: Colour("#051639"), fontWeight: FontWeight.w500),
            subtitle2: TextStyle(fontSize: 12, color: Colour("#051639"), fontWeight: FontWeight.w400),
          )
      ),
      home: const LoginPage(),
    ));
  }
}

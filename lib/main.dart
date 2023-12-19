import 'package:flutter/material.dart';
import 'package:my_room/modules/splash/splash_screen.dart';
import 'package:my_room/navigation/bottom_tabs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const BottomTabs(),
      },
      title: 'QR Code',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

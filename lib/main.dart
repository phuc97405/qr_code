import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/modules/home/bloc/home_bloc.dart';
import 'package:my_room/modules/splash/splash_screen.dart';
import 'package:my_room/navigation/bottom_tabs.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => HomeBloc(),
    child: MyApp(),
  ));
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

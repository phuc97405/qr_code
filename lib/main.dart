import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/modules/home/bloc/home_bloc.dart';
import 'package:my_room/modules/rooms/bloc/room_bloc.dart';
import 'package:my_room/modules/rooms/rooms_screen.dart';
import 'package:my_room/modules/splash/splash_screen.dart';
import 'package:my_room/navigation/bottom_tabs.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (BuildContext context) => HomeBloc(),
      ),
      BlocProvider(
        create: (BuildContext context) => RoomBloc(),
      )
    ],
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
        '/room': (context) => const RoomScreen(),
      },
      title: 'QR Code',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

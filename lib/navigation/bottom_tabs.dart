// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:my_room/modules/home/home_screen.dart';
import 'package:my_room/modules/setting/setting_screen.dart';

class BottomTabs extends StatefulWidget {
  const BottomTabs({super.key});

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            )
          ],
          currentIndex: currentPageIndex,
          selectedItemColor: Colors.black,
          onTap: (int index) {
            switch (index) {
              case 0:
                if (currentPageIndex == index) {}
              case 1:
            }
            setState(
              () {
                currentPageIndex = index;
              },
            );
          },
        ),
        body: <Widget>[
          const HomeScreen(),
          const SettingScreen()
        ][currentPageIndex]);
  }
}

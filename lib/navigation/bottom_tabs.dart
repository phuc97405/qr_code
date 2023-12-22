// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_room/components/snack_bar.dart';
import 'package:my_room/modules/home/home_screen.dart';
import 'package:my_room/modules/rooms/rooms_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BottomTabs extends StatefulWidget {
  const BottomTabs({super.key});

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void _shareFile() async {
    final directory = await getExternalStorageDirectory();
    // getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory?.path}/users.csv';
    if (path.isEmpty) {
      // ignore: use_build_context_synchronously
      ShowSnackBar().showSnackbar(context, 'User export is empty!');
      return;
    }
    // File f = await File(path).create(recursive: true);
    // await f.copy(
    //     "/storage/emulated/0/Download/data_${DateFormat('kk_mm_dd_MM_yyyy').format(DateTime.now())}.csv");
    final files = <XFile>[];
    files.add(XFile(path, name: 'My Users File'));
    Share.shareXFiles(files, text: 'My Users File');
  }

  void _saveFileToDownload() async {
    final directory = await getExternalStorageDirectory();
    // getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory?.path}/users.csv';
    if (path.isEmpty) {
      // ignore: use_build_context_synchronously
      ShowSnackBar().showSnackbar(context, 'User export is empty!');
      return;
    }
    File f = await File(path).create(recursive: true);
    await f.copy(
        "/storage/emulated/0/Download/data_${DateFormat('kk_mm_dd_MM_yyyy').format(DateTime.now())}.csv");
    // ignore: use_build_context_synchronously
    ShowSnackBar().showSnackbar(context, 'Save file to download successfully!');
    // final files = <XFile>[];
    // files.add(XFile(path, name: 'My Users File'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawerScrimColor: Colors.black,
        drawer: Drawer(
          elevation: 16,
          child: ListView(
            padding: const EdgeInsets.all(0.0),
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: const Text("My Room"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'lib/images/logo.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                accountEmail: null,
              ),
              ListTile(
                onTap: scaffoldKey.currentState?.closeDrawer,
                title: const Text("Home"),
                trailing: const Icon(Icons.home),
              ),
              const Divider(),
              ListTile(
                title: const Text("Setting Room Price"),
                trailing: const Icon(Icons.price_change),
                onTap: () => {},
              ),
              const Divider(),
              ListTile(
                  title: const Text("Share Files"),
                  trailing: const Icon(Icons.share),
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    _shareFile();
                  }),
              const Divider(),
              ListTile(
                  title: const Text("Save File To Download"),
                  trailing: const Icon(Icons.save),
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    _saveFileToDownload();
                  }),
              const Divider(),
              ListTile(
                title: const Text("Support"),
                trailing: const Icon(Icons.support_agent),
                onTap: () => {},
              ),
              const Divider(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bed),
              label: 'Rooms',
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
        body: IndexedStack(
          index: currentPageIndex,
          children: [
            HomeScreen(openDrawer: openDrawer),
            SettingScreen(openDrawer: openDrawer)
          ],
        )

        // <Widget>[
        //   HomeScreen(openDrawer: openDrawer),
        //   SettingScreen(openDrawer: openDrawer)
        // ][currentPageIndex]
        );
  }
}

// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_room/components/snack_bar.dart';
import 'package:my_room/modules/home/home_screen.dart';
import 'package:my_room/modules/rooms/rooms_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomTabs extends StatefulWidget {
  const BottomTabs({super.key});

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;
  final String _url = 'https://facebook.com/phuc97405';
  final String _tel = 'tel://0396900698';

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void _shareFile() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/users.csv';
    if (path.isEmpty) {
      // ignore: use_build_context_synchronously
      ShowSnackBar().showSnackbar(context, 'User export is empty!');
      return;
    }
    final files = <XFile>[];
    files.add(XFile(path, name: 'My Users File'));
    Share.shareXFiles(files, text: 'My Users File');
  }

  void _saveFileToDownload() async {
    final directory = await getExternalStorageDirectory();
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
  }

  void _launchURL() async {
    // ignore: deprecated_member_use
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  void _launchTel() async {
    // ignore: deprecated_member_use
    if (!await launch(_tel)) throw 'Could not launch $_tel';
  }

  void showAlertDialog(context) => showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to storage & camera'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => openAppSettings(),
              child: const Text('Settings'),
            ),
          ],
        ),
      );
  Future<bool> _checkPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.camera, Permission.storage].request();

    if (statuses[Permission.camera] == PermissionStatus.granted &&
        statuses[Permission.storage] == PermissionStatus.granted) {
      return true;
    } else {
      print(false);
      // ignore: use_build_context_synchronously
      showAlertDialog(context);
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawerScrimColor: Colors.black,
        drawer: Drawer(
          elevation: 16,
          child: Column(
              // padding: const EdgeInsets.all(0.0),
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName:
                      Text(currentPageIndex == 0 ? "My Users" : "My Room"),
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
                  title: const Text("Setting Room Price(Update)"),
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
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: _launchURL,
                        child: Image.asset(
                          'lib/images/fb.png',
                          width: 40,
                          height: 40,
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: _launchTel,
                        child: Image.asset(
                          'lib/images/call.png',
                          width: 40,
                          height: 40,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                )
              ]
              // .animate(interval: .250.seconds).slideX(),
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
            RoomScreen(openDrawer: openDrawer)
          ],
        ));
  }
}

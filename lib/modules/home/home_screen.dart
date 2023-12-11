import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:my_room/components/base_widgets.dart';
import 'package:my_room/extensions/context_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InfoModel> data = [];

  Future<void> _scanQRNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#7FFF94', 'Cancel', true, ScanMode.BARCODE);
      // ignore: unrelated_type_equality_checks
      if (!mounted || barcodeScanRes == -1) return;
      setState(() {
        final mapList = barcodeScanRes.split('|').toList();
        if (mapList.length != 7) return;
        var indexExist = data.indexWhere((element) =>
            element.cccd == '${mapList[0]}/${mapList[1]}' && element.isCheckIn);
        if (indexExist == -1) {
          data.insert(
              0,
              InfoModel(
                  isCheckIn: true,
                  id: '${UniqueKey().hashCode}',
                  cccd: '${mapList[0]}/${mapList[1]}',
                  name: mapList[2],
                  birthDay: mapList[3],
                  gender: mapList[4],
                  address: mapList[5],
                  createdDate: mapList[6],
                  createAdd:
                      DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now()),
                  updateAt: ''));
        } else {
          data[indexExist].isCheckIn = !data[indexExist].isCheckIn;
          data[indexExist].updateAt =
              DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now());
        }
        _writeCsvFile();
        showSnackbar('Saving...');
      });
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFileCsv();
  }

  Widget _emptyWidget() {
    return Center(
      child: Image.asset(
        'lib/images/img_empty.png',
        width: 300,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  void _loadFileCsv() async {
    final directory =
        await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory.path}/users.csv';
    List<InfoModel> usersMap = [];
    final checkPathExistence = await Directory(path).exists();
    if (!checkPathExistence) return;
    final input = File(path).openRead();
    List mapList = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    mapList.removeAt(0);
    if (mapList.isNotEmpty) {
      mapList.forEach((element) {
        usersMap.add(InfoModel(
            id: '${element[0]}',
            cccd: '${element[1]}',
            name: '${element[2]}',
            birthDay: '${element[3]}',
            gender: '${element[4]}',
            address: '${element[5]}',
            createdDate: '${element[6]}',
            createAdd: '${element[7]}',
            isCheckIn: element[8],
            updateAt: '${element[9]}'));
      });
      setState(() {
        data.insertAll(0, usersMap);
      });
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
      String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
    ));
  }

  void _shareFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory.path}/users.csv';
    if (path.isEmpty) return;

    final files = <XFile>[];
    files.add(XFile(path, name: 'My Users File'));
    Share.shareXFiles(files, text: 'My Users File');
  }

  Future<void> _dialogDelete(BuildContext context, int index) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notion'),
          content: const Text(
            'Are you sure you want to delete it?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  data.removeAt(index);
                });
                _writeCsvFile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget viewButton(IconData icon, String value, String type) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.black38.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 25,
              color: Colors.black,
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  type,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        )
        //  ListTile(
        //     tileColor: Colors.grey,
        //     leading: Icon(
        //       icon,
        //       size: 30,
        //       color: Colors.grey,
        //     ),
        //     title: Text(
        //       value,
        //       style: const TextStyle(color: Colors.red),
        //     )),
        );
  }

  Future showBottomSheet(InfoModel user) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: context.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      viewButton(Icons.timelapse_sharp, '2H', 'Timer'),
                      viewButton(Icons.numbers, '202', 'Room'),
                      viewButton(Icons.star_outline_sharp,
                          user.updateAt.isEmpty ? 'In' : 'Out', 'Status'),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: user.isCheckIn
                            ? Colors.green[100]
                            : Colors.red[100],
                        border: Border.all(
                            width: 2,
                            color:
                                (user.isCheckIn ? Colors.green : Colors.red))),
                    child: Column(children: [
                      BaseWidgets.instance.rowInfo('Name: ', user.name),
                      //  BaseWidgets(('Tên: ', info[index].name),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo('Gender: ', user.gender),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo(
                        'Birth: ',
                        user.birthDay
                            .replaceRange(2, 2, '-')
                            .replaceRange(5, 5, '-'),
                      ),

                      BaseWidgets.instance.rowInfo(
                          'Data Range: ',
                          user.createdDate
                              .replaceRange(2, 2, '-')
                              .replaceRange(5, 5, '-')),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo('CCCD: ', user.cccd),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo('CheckIn: ', user.createAdd),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo('CheckOut: ',
                          user.updateAt.isNotEmpty ? user.updateAt : '---'),
                      const SizedBox(
                        height: 5,
                      ),
                      BaseWidgets.instance.rowInfo('Address: ', user.address),
                    ]),
                  ),
                ],
              ),
            ),
          );
        });
  }

  List<Widget> _infoUser(List<InfoModel> info) {
    return List.generate(
        info.length,
        (index) => GestureDetector(
              onLongPress: () {
                _dialogDelete(context, index);
              },
              onTap: () {
                showBottomSheet(info[index]);
              },
              child: Stack(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 40, 5, 5),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: info[index].isCheckIn
                          ? Colors.green[100]
                          : Colors.red[100],
                      border: Border.all(
                          width: 1,
                          color: (info[index].isCheckIn
                              ? Colors.green
                              : Colors.red))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BaseWidgets.instance
                            .rowInfo('Name: ', info[index].name),
                        const SizedBox(
                          height: 5,
                        ),
                        BaseWidgets.instance
                            .rowInfo('Gender: ', info[index].gender),
                        const SizedBox(
                          height: 5,
                        ),
                        BaseWidgets.instance.rowInfo(
                          'Birth: ',
                          info[index]
                              .birthDay
                              .replaceRange(2, 2, '-')
                              .replaceRange(5, 5, '-'),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(info[index].createAdd,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w300)),
                      ]),
                ),
                Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Text(
                          (info[index].isCheckIn ? 'IN' : "OUT"),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: (info[index].isCheckIn
                                  ? Colors.green
                                  : Colors.red)),
                        ))),
              ]),
            ));
  }

  void _writeCsvFile() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      List<List<dynamic>> rows = [];
      List<dynamic> row = [];
      row.add("id");
      row.add("cccd");
      row.add("name");
      row.add("birthDay");
      row.add("gender");
      row.add("address");
      row.add("createdDate");
      row.add("createAdd");
      row.add("isCheckIn");
      row.add("updateAt");
      rows.add(row);
      for (int i = 0; i < data.length; i++) {
        List<dynamic> row = [];
        row.add(data[i].id);
        row.add(data[i].cccd);
        row.add(data[i].name);
        row.add(data[i].birthDay);
        row.add(data[i].gender);
        row.add(data[i].address);
        row.add(data[i].createdDate);
        row.add(data[i].createAdd);
        row.add(data[i].isCheckIn);
        row.add(data[i].updateAt);
        rows.add(row);
      }
      String csv = const ListToCsvConverter().convert(rows);
      final directory =
          await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
      final path = '${directory.path}/users.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print(ex);
    }
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green[300],
          leading: GestureDetector(
              onTap: () {
                if (data.isNotEmpty) {
                  _shareFile();
                } else {
                  showSnackbar('User export is empty!');
                }
              },
              child: Icon(
                Icons.share,
                color: data.isNotEmpty ? Colors.black : Colors.black54,
                size: 30,
              )),
          leadingWidth: 50,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 10),
          //     child: GestureDetector(
          //         onTap: () {
          //           if (!isSave) {
          //             _writeCsvFile();
          //             setState(() {
          //               isSave = true;
          //             });
          //             showSnackbar('Saving...');
          //           } else {
          //             showSnackbar('Please Add User With QR Code !!!');
          //           }
          //         },
          //         child: Icon(
          //           Icons.save,
          //           color: isSave ? Colors.black54 : Colors.black,
          //           size: 30,
          //         )),
          //   ),
          // ],
          title: const Text(
            "My Room",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'scan', // used by assistive technologies
          onPressed: _scanQRNormal,
          backgroundColor: Colors.green[100],
          child: const Icon(
            Icons.qr_code,
            color: Colors.green,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.green,
          selectedIndex: currentPageIndex,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.settings_outlined)),
              label: 'Settings',
            ),
          ],
        ),
        body: <Widget>[
          data.isEmpty
              ? _emptyWidget()
              : GridView.count(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 2,
                  children: _infoUser(data)),
          const Text('Settings')
        ][currentPageIndex]);
  }
}

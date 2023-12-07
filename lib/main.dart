import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code/models/info_model.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<InfoModel> data = [];
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  bool isSave = true;

  Future<void> scanQRNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#7FFF94', 'Cancel', true, ScanMode.BARCODE);
      // ignore: unrelated_type_equality_checks
      if (!mounted || barcodeScanRes == -1) return;
      setState(() {
        isSave = false;
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
                      DateFormat('dd-MM-yyyy kk:mm').format(DateTime.now()),
                  updateAt: ''));
        } else {
          data[indexExist].isCheckIn = !data[indexExist].isCheckIn;
          data[indexExist].updateAt =
              DateFormat('dd-MM-yyyy kk:mm').format(DateTime.now());
        }
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
    loadFileCsv();
  }

  Widget emptyWidget() {
    return Center(
      child: Image.asset(
        'lib/images/img_empty.png',
        width: 300,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  void loadFileCsv() async {
    final directory =
        await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory.path}/user_data.csv';
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

  void shareFile() async {
    print('aaa');
    final directory =
        await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path =
        '${directory.path}/user_data.csv'; //data/user/0/com.example.qr_code/app_flutter
    if (path.isEmpty) return;

    final files = <XFile>[];
    files.add(XFile(path, name: 'My Data File'));
    Share.shareXFiles(files, text: 'My Data File');
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

  Widget infoUser(List<InfoModel> info) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            info.length,
            (index) => GestureDetector(
                  onLongPress: () {
                    _dialogDelete(context, index);
                  },
                  child: Stack(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              width: 2,
                              color: (info[index].isCheckIn
                                  ? Colors.green
                                  : Colors.red))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: 'CCCD/CMT: ',
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                    children: [
                                  TextSpan(
                                      text: info[index].cccd,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold))
                                ])),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(children: [
                              const Text('Họ Và Tên: ',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey)),
                              Flexible(
                                child: Text(info[index].name,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                              )
                            ]),
                            Row(children: [
                              const Text('Ngày Sinh: ',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey)),
                              Flexible(
                                child: Text(
                                    info[index]
                                        .birthDay
                                        .replaceRange(2, 2, '-')
                                        .replaceRange(5, 5, '-'),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                              )
                            ]),
                            const SizedBox(
                              height: 5,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: 'Giới Tính: ',
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                    children: [
                                  TextSpan(
                                      text: info[index].gender,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold))
                                ])),
                            const SizedBox(
                              height: 5,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: 'Ngày Cấp: ',
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                    children: [
                                  TextSpan(
                                      text: info[index]
                                          .createdDate
                                          .replaceRange(2, 2, '-')
                                          .replaceRange(5, 5, '-'),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold))
                                ])),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Thường Trú: ',
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.grey)),
                                  Flexible(
                                    child: Text(info[index].address,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ]),
                            const SizedBox(
                              height: 5,
                            ),
                          ]),
                    ),
                    Positioned(
                        right: 20,
                        top: 20,
                        child: Text(
                          (info[index].isCheckIn ? 'IN' : "OUT"),
                          style: TextStyle(
                              fontSize: 20,
                              color: (info[index].isCheckIn
                                  ? Colors.green
                                  : Colors.red)),
                        )),
                    Positioned(
                        left: 20,
                        bottom: 12,
                        child: Text(info[index].createAdd)),
                    Positioned(
                        right: 20,
                        bottom: 12,
                        child: Text(info[index].updateAt)),
                  ]),
                )).toList());
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
      final path = '${directory.path}/user_data.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green[300],
          leading: GestureDetector(
              onTap: () {
                if (isSave && data.isNotEmpty) {
                  shareFile();
                } else {
                  showSnackbar('Please Save File !!!');
                }
              },
              child: Icon(
                Icons.share,
                color:
                    isSave && data.isNotEmpty ? Colors.black : Colors.black54,
                size: 30,
              )),
          leadingWidth: 50,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                  onTap: () {
                    if (!isSave) {
                      _writeCsvFile();
                      setState(() {
                        isSave = true;
                      });
                      showSnackbar('Saving...');
                    } else {
                      showSnackbar('Please Add User With QR Code !!!');
                    }
                  },
                  child: Icon(
                    Icons.save,
                    color: isSave ? Colors.black54 : Colors.black,
                    size: 30,
                  )),
            ),
          ],
          title: const Text(
            "QR Code",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: data.isEmpty
            ? emptyWidget()
            : SingleChildScrollView(child: infoUser(data)),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add User', // used by assistive technologies
          onPressed: scanQRNormal,
          backgroundColor: Colors.green[100],
          child: const Icon(
            Icons.qr_code,
            color: Colors.green,
          ),
        ));
  }
}

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // '052099013346|215465826|Lê Ngọc Phúc|01011999|Nam|Xóm Cầu Sào, Thôn Mỹ Bình, Cát Thắng, Phù Cát, Bình Định|15032022';

  List<InfoModel> data = [];

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (!mounted) return;
    setState(() {
      final mapList = barcodeScanRes.split('|').toList();
      // print(mapList);
      data.add(InfoModel(
          cccd: '${mapList[0]}/${mapList[1]}',
          name: mapList[2],
          birthDay: mapList[3],
          gender: mapList[4],
          address: mapList[5],
          createdDate: mapList[6],
          createAdd:
              DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now())));
      // _scanBarcodeResult = barcodeScanRes;
    });
  }

  void shareFile() async {
    print('aaa');
    final root =
        await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path =
        '${root?.path}/user_data.csv'; //data/user/0/com.example.qr_code/app_flutter
    final files = <XFile>[];
    files.add(XFile(path, name: 'Gear Back Up'));

    /// Share Plugin
    Share.shareXFiles(files, text: 'My Exported Data!');
  }

  Widget infoUser(List<InfoModel> info) {
    // print(info);
    if (info.isEmpty) {
      return ElevatedButton(
        onPressed: shareFile,
        child: const Text(
          'Data Is Empty!!!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
    }
    return Column(
        children: List.generate(
            info.length,
            (index) => Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 1, color: Colors.black26)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '_CCCD/CMT: ${info[index].cccd}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_Họ Và Tên: ${info[index].name}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_Ngày Sinh: ${info[index].birthDay}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_Giới Tính: ${info[index].gender}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_ĐC Thường trú: ${info[index].address}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_Ngày Cấp: ${info[index].createdDate}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '_Tạo Lúc: ${info[index].createAdd}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )
                      ]),
                )).toList());
  }

  void _generateCsvFile() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      List<List<dynamic>> rows = [];

      List<dynamic> row = [];
      row.add("stt");
      row.add("cccd");
      row.add("name");
      row.add("birthDay");
      row.add("gender");
      row.add("address");
      row.add("createdDate");
      row.add("createAdd");
      rows.add(row);
      for (int i = 0; i < data.length; i++) {
        List<dynamic> row = [];
        row.add(i + 1);
        row.add(data[i].cccd);
        row.add(data[i].name);
        row.add(data[i].birthDay);
        row.add(data[i].gender);
        row.add(data[i].address);
        row.add(data[i].createdDate);
        row.add(data[i].createAdd);
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);
      final root =
          await getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
      final path = '${root?.path}/user_data.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print(ex);
    }
    // await Share.shareFiles([path], subject: 'Shared file');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: _generateCsvFile, child: const Icon(Icons.summarize))
        ],
        title: const Text("QR Code & Barcode Scanner"),
      ),
      body: Center(
        child: SingleChildScrollView(child: infoUser(data)),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add User', // used by assistive technologies
        onPressed: scanBarcodeNormal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

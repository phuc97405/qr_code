import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_room/components/base_widgets.dart';
import 'package:my_room/components/snack_bar.dart';
import 'package:my_room/constants/enums/date_enum.dart';
import 'package:my_room/models/room_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingScreen extends StatefulWidget {
  final Function openDrawer;
  const SettingScreen({super.key, required this.openDrawer});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController roomController = TextEditingController();
  TextEditingController peopleController = TextEditingController(text: '2');

  List<RoomModel> listRoom = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFileRoom();
    print('init state room');
  }

  void _loadFileRoom() async {
    final directory = await getExternalStorageDirectory();
    // getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/app_flutter
    final path = '${directory?.path}/rooms.csv';
    List<RoomModel> roomsMap = [];
    final checkPathExistence = await File(path).exists();
    // await Directory(directory!.path).exists();
    if (!checkPathExistence) return;
    final input = File(path).openRead();
    List mapList = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    mapList.removeAt(0); //remove row properties key
    if (mapList.isNotEmpty) {
      mapList.forEach((element) {
        roomsMap.add(RoomModel(
          id: '${element[0]}',
          status: '${element[1]}',
          timer: '${element[2]}',
          room: '${element[3]}',
          name: '${element[4]}',
          cccd: '${element[5]}',
          people: '${element[6]}',
        ));
      });
      setState(() {
        listRoom.insertAll(0, roomsMap);
      });
    }
  }

  void _writeRoomFile() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      List<List<dynamic>> rows = [];
      List<dynamic> row = [];
      row.add("id");
      row.add("status");
      row.add("timer");
      row.add("room");
      row.add("name");
      row.add("cccd");
      row.add("people");
      rows.add(row);
      for (int i = 0; i < listRoom.length; i++) {
        List<dynamic> row = [];
        row.add(listRoom[i].id);
        row.add(listRoom[i].status);
        row.add(listRoom[i].timer);
        row.add(listRoom[i].room);
        row.add(listRoom[i].name);
        row.add(listRoom[i].cccd);
        row.add(listRoom[i].people);
        rows.add(row);
      }
      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getExternalStorageDirectory();
      // getApplicationDocumentsDirectory(); //data/user/0/com.example.qr_code/files
      final path = '${directory?.path}/rooms.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print(ex);
    }
  }

  void handleAddRoom() {
    setState(() {
      listRoom.add(RoomModel(
          id: '${UniqueKey().hashCode}',
          cccd: '',
          name: '',
          people: peopleController.text,
          room: roomController.text,
          status: roomStatusE.Available.name,
          timer: ''));
    });
    _writeRoomFile();
  }

  Future<void> _dialogCreateRoom(
    BuildContext context,
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Create Room',
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room Number:',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300)),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: roomController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  hintText: 'Example 202',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Max People:',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300)),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: peopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  hintText: 'Example 1',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
            ],
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
              child: const Text('Create'),
              onPressed: () {
                if (roomController.text.isNotEmpty &&
                    int.parse(peopleController.text) > 0) {
                  handleAddRoom();
                  Navigator.of(context).pop();
                } else {
                  ShowSnackBar().showSnackbar(
                      context, 'Please enter room number & people');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Color renderColorStatus(String type) {
    switch (type) {
      case 'CheckIn':
        return Colors.green;
      case 'CheckOut':
        return Colors.red;
      default:
        return Colors.black12;
    }
  }

  List<Widget> renderItemRooms() {
    return List.generate(
      listRoom.length,
      (index) => Stack(children: [
        Container(
          padding: const EdgeInsets.only(left: 10, top: 35),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: renderColorStatus(listRoom[index].status).withOpacity(0.3),
              border: Border.all(
                  width: 1, color: renderColorStatus(listRoom[index].status))),
          child: Column(children: [
            BaseWidgets.instance.rowInfo('Timer: ',
                listRoom[index].timer.isEmpty ? '---' : listRoom[index].timer),
            const SizedBox(
              height: 5,
            ),
            BaseWidgets.instance.rowInfo('Room: ',
                listRoom[index].room.isEmpty ? '---' : listRoom[index].room),
            const SizedBox(
              height: 5,
            ),
            BaseWidgets.instance.rowInfo('Name: ',
                listRoom[index].name.isEmpty ? '---' : listRoom[index].name),
            const SizedBox(
              height: 5,
            ),
            BaseWidgets.instance
                .rowInfo('Max People: ', listRoom[index].people),
            const SizedBox(
              height: 5,
            ),
          ]),
        ),
        Positioned(
            right: 8,
            top: 8,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text((listRoom[index].status),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                        // renderColorStatus(listRoom[index].status),
                        )))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          leading: GestureDetector(
              onTap: () => widget.openDrawer(),
              child: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 30,
              )),
          leadingWidth: 50,
          title: const Text(
            "My Room",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'addRoom',
          tooltip: 'scan', // used by assistive technologies
          onPressed: () => _dialogCreateRoom(context),
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        body: GestureDetector(
            onTap: () {},
            child: GridView.count(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 2,
                children: renderItemRooms())));
  }
}

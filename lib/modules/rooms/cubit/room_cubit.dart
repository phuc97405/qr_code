import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_room/constants/enums/date_enum.dart';
import 'package:my_room/extensions/date_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:my_room/models/room_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomInitial());

  void roomLoadFileLocal() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/rooms.csv';
    List<RoomModel> roomsMap = [];
    final checkPathExistence = await File(path).exists();
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
          people: '${element[5]}',
        ));
      });
      emit(RoomState(listRoom: roomsMap));
    }
  }

  void roomAdd(String roomCode, String roomPeople, String roomStatus) {
    try {
      List<RoomModel> listNew = [...state.listRoom];
      final checkExist =
          listNew.indexWhere((element) => element.room == roomCode);
      print(checkExist);
      if (checkExist == -1) {
        listNew.add(RoomModel(
          id: '${UniqueKey().hashCode}',
          status: roomStatus,
          timer: '',
          room: roomCode,
          name: '',
          people: roomPeople,
        ));

        emit(RoomState(listRoom: listNew));
        _writeRoomFile();
      }
      print('user is existing');
      // emit(RoomState.errorAdd(listNew, 'user is exist'));
    } catch (e) {
      print(e);
    }
  }

  void roomRemove(int index) {
    List<RoomModel> listNew = [...state.listRoom];
    listNew.removeAt(index);
    emit(RoomState(listRoom: listNew));
    // _writeRoomFile();
  }

  void roomUpdate(String timer, String name, String status, String room) {
    try {
      List<RoomModel> listNew = [...state.listRoom];

      final checkIndex = listNew.indexWhere((element) => element.room == room);
      listNew[checkIndex].name = name;
      listNew[checkIndex].status = status;
      listNew[checkIndex].timer = timer;
      emit(RoomState(listRoom: listNew));
      _writeRoomFile();
    } catch (e) {
      print('RoomUpdate$e');
    }
  }

  void updateAllRoom(List<InfoModel> listUsers) {
    try {
      List<RoomModel> listRooms = [...state.listRoom];
      if (listRooms.isEmpty || listUsers.isEmpty) {
        return;
      }
      for (var user in listUsers) {
        var indexRoom = listRooms.indexWhere((e) => user.room == e.room);
        if (indexRoom != -1) {
          listRooms[indexRoom].name = user.name;
          listRooms[indexRoom].status =
              user.isCheckIn ? roomStatusE.In.name : roomStatusE.Out.name;
          listRooms[indexRoom].timer = DateTime.now()
              .aboutHour(user.updateAt, user.createAt); // checkin to checkout
        } else {
          listRooms[indexRoom].status = roomStatusE.Available.name;
          listRooms[indexRoom].name = '';
          listRooms[indexRoom].timer = '';
        }
      }
      emit(RoomState(listRoom: listRooms));
      _writeRoomFile();
    } catch (e) {
      print('updateAllRoom$e');
    }
  }

  void _writeRoomFile() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses);
      List<List<dynamic>> rows = [];
      List<dynamic> row = [];
      row.add("id");
      row.add("status");
      row.add("timer");
      row.add("room");
      row.add("name");
      row.add("people");
      rows.add(row);
      for (int i = 0; i < state.listRoom.length; i++) {
        List<dynamic> row = [];
        row.add(state.listRoom[i].id);
        row.add(state.listRoom[i].status);
        row.add(state.listRoom[i].timer);
        row.add(state.listRoom[i].room);
        row.add(state.listRoom[i].name);
        row.add(state.listRoom[i].people);
        rows.add(row);
      }
      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/rooms.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print(ex);
    }
  }
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:bloc/bloc.dart';
// import 'package:csv/csv.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:my_room/models/room_model.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// part 'room_event.dart';
// part 'room_state.dart';

// class RoomBloc extends Bloc<RoomEvent, RoomState> {
//   RoomBloc() : super(const RoomState.initial([])) {
//     on<RoomLoadData>((event, emit) async {
//       final directory = await getExternalStorageDirectory();
//       final path = '${directory?.path}/rooms.csv';
//       List<RoomModel> roomsMap = [];
//       final checkPathExistence = await File(path).exists();
//       if (!checkPathExistence) return;
//       final input = File(path).openRead();
//       List mapList = await input
//           .transform(utf8.decoder)
//           .transform(const CsvToListConverter())
//           .toList();
//       mapList.removeAt(0); //remove row properties key
//       if (mapList.isNotEmpty) {
//         mapList.forEach((element) {
//           roomsMap.add(RoomModel(
//             id: '${element[0]}',
//             status: '${element[1]}',
//             timer: '${element[2]}',
//             room: '${element[3]}',
//             name: '${element[4]}',
//             people: '${element[5]}',
//           ));
//         });
//         emit(RoomState.loadData(roomsMap));
//       }
//     });

//     on<RoomAdd>((event, emit) {
//       try {
//         List<RoomModel> listNew = [...state.listRoom];
//         final checkExist =
//             listNew.indexWhere((element) => element.room == event.roomCode);
//         print(checkExist);
//         if (checkExist == -1) {
//           listNew.add(RoomModel(
//             id: '${UniqueKey().hashCode}',
//             status: event.roomStatus,
//             timer: '',
//             room: event.roomCode,
//             name: '',
//             people: event.roomPeople,
//           ));

//           emit(RoomState.loadData(listNew));
//           _writeRoomFile();
//         }
//         print('user is existing');
//         // emit(RoomState.errorAdd(listNew, 'user is exist'));
//       } catch (e) {
//         print(e);
//       }
//     });

//     on<RoomDelete>((event, emit) {
//       List<RoomModel> listNew = [...state.listRoom];
//       listNew.removeAt(event.index);
//       emit(RoomState.loadData(listNew));
//       _writeRoomFile();
//     });
//     on<RoomUpdate>((event, emit) {
//       try {
//         List<RoomModel> listNew = [...state.listRoom];

//         final checkIndex =
//             listNew.indexWhere((element) => element.room == event.room);
//         listNew[checkIndex].name = event.name;
//         listNew[checkIndex].status = event.status;
//         listNew[checkIndex].timer = event.timer;
//         emit(RoomState.loadData(listNew));
//         _writeRoomFile();
//       } catch (e) {
//         print('RoomUpdate$e');
//       }
//     });
//   }

//   void _writeRoomFile() async {
//     try {
//       Map<Permission, PermissionStatus> statuses = await [
//         Permission.storage,
//       ].request();
//       print(statuses);
//       List<List<dynamic>> rows = [];
//       List<dynamic> row = [];
//       row.add("id");
//       row.add("status");
//       row.add("timer");
//       row.add("room");
//       row.add("name");
//       row.add("people");
//       rows.add(row);
//       for (int i = 0; i < state.listRoom.length; i++) {
//         List<dynamic> row = [];
//         row.add(state.listRoom[i].id);
//         row.add(state.listRoom[i].status);
//         row.add(state.listRoom[i].timer);
//         row.add(state.listRoom[i].room);
//         row.add(state.listRoom[i].name);
//         row.add(state.listRoom[i].people);
//         rows.add(row);
//       }
//       String csv = const ListToCsvConverter().convert(rows);
//       final directory = await getExternalStorageDirectory();
//       final path = '${directory?.path}/rooms.csv';
//       File f = await File(path).create(recursive: true);
//       await f.writeAsString(csv);
//     } on PlatformException catch (ex) {
//       print(ex);
//     } catch (ex) {
//       print(ex);
//     }
//   }
// }

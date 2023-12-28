import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/extensions/date_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState.initial([])) {
    on<HomeLoadData>((event, emit) async {
      try {
        final directory = await getExternalStorageDirectory();
        final path = '${directory?.path}/users.csv';
        List<InfoModel> usersMap = [];
        final checkPathExistence = await File(path).exists();
        if (!checkPathExistence) return;
        final input = File(path).openRead();
        List mapList = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();
        mapList.removeAt(0); //remove row properties key
        if (mapList.isNotEmpty) {
          for (var element in mapList) {
            usersMap.add(InfoModel(
              id: '${element[0]}',
              cccd: '${element[1]}',
              name: '${element[2]}',
              birthDay: '${element[3]}',
              gender: '${element[4]}',
              address: '${element[5]}',
              createdDate: '${element[6]}',
              createAt: '${element[7]}',
              isCheckIn: bool.parse('${element[8]}'),
              updateAt: '${element[9]}',
              room: '${element[10]}',
            ));
          }
          emit(HomeState.setData(
            usersMap,
          ));
        }
      } catch (e) {
        print('HomeLoadData: $e');
      }
    });

    // ignore: void_checks
    on<HomeRemoverItem>((event, emit) {
      try {
        List<InfoModel> listNew = state.listUsers.map((e) => e).toList();
        listNew.removeAt(event.indexItemRemove);
        emit(HomeState.setData(listNew));
        _writeFileCsv();
      } catch (e) {
        print('HomeRemoverItem$e');
      }
    });

    on<HomeScanQR>((event, emit) async {
      try {
        final checkPermission = await _checkPermission(Permission.camera);
        if (!checkPermission) {
          openAppSettings();
          return;
        }
        print('currentState: $state');
        String barcodeScanRes;
        List<InfoModel> listNew = [...state.listUsers];
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#7FFF94', 'Cancel', true, ScanMode.BARCODE);
        // ignore: unrelated_type_equality_checks
        if (barcodeScanRes == -1) return;
        final mapList = barcodeScanRes.split('|').toList();
        if (mapList.length != 7) return;
        var indexExist = listNew.indexWhere((element) =>
            element.cccd == '${mapList[0]}/${mapList[1]}' &&
            element.isCheckIn &&
            DateTime.now().isSameDate(
                DateTime.now(),
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(element.createAt))));
        if (indexExist != -1) {
          listNew[indexExist].isCheckIn = !listNew[indexExist].isCheckIn;
          listNew[indexExist].updateAt =
              DateTime.now().millisecondsSinceEpoch.toString();
          // DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now());
          emit(HomeState.setData(listNew));
        } else {
          emit(HomeState.setData([
            InfoModel(
                isCheckIn: true,
                id: '${UniqueKey().hashCode}',
                cccd: '${mapList[0]}/${mapList[1]}',
                name: mapList[2],
                birthDay: mapList[3],
                gender: mapList[4],
                address: mapList[5],
                createdDate: mapList[6],
                createAt: DateTime.now().millisecondsSinceEpoch.toString(),
                // DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now()),
                updateAt: '',
                room: ''),
            ...state.listUsers
          ]));
        }
        _writeFileCsv();
        // ShowSnackBar().showSnackbar(context, 'Saving...');
        // } on PlatformException {
        //   barcodeScanRes = "Failed to get platform version.";
      } catch (e) {
        print('HomeScanQR$e');
      }
    });

    on<HomeAddRoomToUser>((event, emit) {
      try {
        List<InfoModel> listNew = [...state.listUsers];
        final i = listNew.indexWhere((element) => event.id == element.id);
        listNew[i].room = event.room;
        _writeFileCsv();
        emit(HomeState.setData(listNew));
      } catch (e) {
        print('HomeAddRoomToUser$e');
      }
    });
  }

  Future<bool> _checkPermission(Permission permission) async {
    var status = await permission.request();
    return status.isGranted;
    // if (status == PermissionStatus.granted) {
    //   print('Permission granted');
    //   return true;
    // } else if (status == PermissionStatus.denied) {
    //   showAlertDialog(context);
    //   print(
    //       'Permission denied. Show a dialog and again ask for the permission');
    //   return false;
    // } else if (status == PermissionStatus.permanentlyDenied) {
    //   print('Take the user to the settings page.');
    // }
    // return false;
  }

  void _writeFileCsv() async {
    try {
      final checkPermission = await _checkPermission(Permission.storage);
      if (!checkPermission) {
        openAppSettings();
        return;
      }
      List<List<dynamic>> rows = [];
      List<dynamic> row = [];
      row.add("id");
      row.add("cccd");
      row.add("name");
      row.add("birthDay");
      row.add("gender");
      row.add("address");
      row.add("createdDate");
      row.add("createAt");
      row.add("isCheckIn");
      row.add("updateAt");
      row.add("room");
      rows.add(row);
      for (int i = 0; i < state.listUsers.length; i++) {
        List<dynamic> row = [];
        row.add(state.listUsers[i].id);
        row.add(state.listUsers[i].cccd);
        row.add(state.listUsers[i].name);
        row.add(state.listUsers[i].birthDay);
        row.add(state.listUsers[i].gender);
        row.add(state.listUsers[i].address);
        row.add(state.listUsers[i].createdDate);
        row.add(state.listUsers[i].createAt);
        row.add(state.listUsers[i].isCheckIn);
        row.add(state.listUsers[i].updateAt);
        row.add(state.listUsers[i].room);
        rows.add(row);
      }
      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/users.csv';
      File f = await File(path).create(recursive: true);
      await f.writeAsString(csv);
    } on PlatformException catch (ex) {
      print(ex);
    } catch (ex) {
      print('_writeFileCsv$ex');
    }
  }
}

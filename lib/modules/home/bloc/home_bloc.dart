import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/extensions/date_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:my_room/services/api_provider.dart';
import 'package:my_room/services/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    MyApiProvide myApiProvide = MyApiProvide();
    Repository response = Repository(myApiProvide);
    on<HomeLoadData>((event, emit) async {
      try {
        List<DateTime> listDate = List<DateTime>.generate(
            30,
            (i) => DateTime.utc(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).subtract(Duration(days: i)));
        // ignore: unrelated_type_equality_checks
        emit(state.copyWith(status: HomeStatus.loading, listDate: listDate));
        if (await Permission.storage.status != PermissionStatus.granted) return;
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
          // emit(HomeState.setData(usersMap));
          emit(state.copyWith(listUsers: usersMap, status: HomeStatus.success));
        }
      } catch (e) {
        emit(state.copyWith(status: HomeStatus.failure));
        print('HomeLoadData: $e');
      } finally {
        emit(state.copyWith(
          status: HomeStatus.success,
        ));
      }
    });

    // ignore: void_checks
    on<HomeRemoverItem>((event, emit) {
      try {
        emit(state.copyWith(status: HomeStatus.loading));
        List<InfoModel> listNew = state.listUsers.map((e) => e).toList();
        listNew.removeAt(event.indexItemRemove);
        emit(state.copyWith(listUsers: listNew, status: HomeStatus.success));
        // emit(HomeState.setData(listNew));
        _writeFileCsv();
      } catch (e) {
        emit(state.copyWith(status: HomeStatus.failure));
        print('HomeRemoverItem$e');
      }
    });

    on<HomeScanQR>((event, emit) async {
      try {
        String barcodeScanRes;
        List<InfoModel> listNew = [...state.listUsers];
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#7FFF94', 'Cancel', true, ScanMode.BARCODE);
        // ignore: unrelated_type_equality_checks
        if (barcodeScanRes == -1) return;
        final mapList = barcodeScanRes.split('|').toList();
        if (mapList.length != 7) return;
        emit(state.copyWith(status: HomeStatus.loading));
        var indexExist = listNew.indexWhere((element) =>
            element.cccd == '${mapList[0]}/${mapList[1]}' &&
            element.isCheckIn &&
            DateTime.now().isSameDate(
                DateTime.now(),
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(element.createAt))));
        if (indexExist != -1) {
          listNew[indexExist].isCheckIn = false;
          listNew[indexExist].updateAt =
              DateTime.now().millisecondsSinceEpoch.toString();
          bool roomIsEmpty = listNew[indexExist].room.isEmpty;
          emit(state.copyWith(
            listUsers: [...listNew],
            indexRoomCheckout: roomIsEmpty ? -1 : indexExist,
            status: roomIsEmpty ? HomeStatus.success : HomeStatus.checkout,
          ));
          // await response.pushDataToAppTelegram(
          //     'Update user: ${listNew[indexExist].toString()}');
        } else {
          emit(state.copyWith(listUsers: [
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
                updateAt: '',
                room: ''),
            ...state.listUsers
          ], status: HomeStatus.success));
          await response.pushDataToAppTelegram('Add user: ${(
            isCheckIn: true,
            cccd: '${mapList[0]}/${mapList[1]}',
            name: mapList[2],
            birthDay: mapList[3],
            gender: mapList[4],
            address: mapList[5],
            createdDate: mapList[6],
            createAt: DateTime.now().millisecondsSinceEpoch.toString(),
          ).toString()}');
        }
        _writeFileCsv();
      } catch (e) {
        emit(state.copyWith(status: HomeStatus.failure));
        print('HomeScanQR$e');
      }
    });

    on<HomeAddRoomToUser>((event, emit) {
      try {
        emit(state.copyWith(status: HomeStatus.loading));
        List<InfoModel> listNew = [...state.listUsers];
        final i = listNew.indexWhere((element) => event.id == element.id);
        listNew[i].room = event.room;
        _writeFileCsv();
        emit(state.copyWith(listUsers: listNew, status: HomeStatus.success));
      } catch (e) {
        emit(state.copyWith(status: HomeStatus.failure));
        print('HomeAddRoomToUser$e');
      }
    });

    on<HomeSetIndexFilterDate>((event, emit) {
      emit(state.copyWith(indexFilterDate: event.index));
    });

    on<HomeSetListDate>((event, emit) {
      emit(state.copyWith(listDate: [...state.listDate, ...event.listDate]));
    });

    on<HomeLoadMoreDate>((event, emit) {
      List<DateTime> dateNew = List<DateTime>.generate(
          31,
          (i) => DateTime.utc(
                state.listDate.last.year,
                state.listDate.last.month,
                state.listDate.last.day,
              ).subtract(Duration(days: i + 1))).toList();
      emit(state.copyWith(listDate: List.of(state.listDate)..addAll(dateNew)));
    });

    on<HomeSetIsShowSearch>((event, emit) {
      emit(state.copyWith(
        isShowInputSearch: event.isShowSearch,
      ));
    });
  }

  void _writeFileCsv() async {
    try {
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

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_room/extensions/date_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:path_provider/path_provider.dart';

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
          mapList.forEach((element) {
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
              room: element[10],
            ));
          });
          emit(HomeState.loadData(usersMap));
          // setState(() {
          //   data.insertAll(0, usersMap);
          // });
        }
      } catch (e) {
        print('error: $e');
      }
    });
    on<HomeScanQR>((event, emit) async {
      String barcodeScanRes;
      List<InfoModel> listNew = state.dateHistory.map((e) => e).toList();
      try {
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
          //   listNew.map((e) {
          //     var index = listNew.indexOf(e);
          //     if (index == indexExist) {
          //       return {
          //         ...e,
          //         e.isCheckIn: false,
          //       };
          //     } else
          //       return e;
          //   }).toList();
          listNew[indexExist].isCheckIn = !listNew[indexExist].isCheckIn;
          listNew[indexExist].updateAt =
              DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now());

          // listNew[indexExist]={...listNew[indexExist],isCheckIn:false,updateAt:DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now())}

          emit(HomeState.loadData(listNew));
        } else {
          emit(HomeState.loadData([
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
            ...state.dateHistory
          ]));
          // event.listData.insert(
          //     0,
          //     InfoModel(
          //         isCheckIn: true,
          //         id: '${UniqueKey().hashCode}',
          //         cccd: '${mapList[0]}/${mapList[1]}',
          //         name: mapList[2],
          //         birthDay: mapList[3],
          //         gender: mapList[4],
          //         address: mapList[5],
          //         createdDate: mapList[6],
          //         createAt: DateTime.now().millisecondsSinceEpoch.toString(),
          //         // DateFormat('kk:mm dd/MM/yyyy').format(DateTime.now()),
          //         updateAt: '',
          //         room: ''));
        }
        // _writeCsvFile();
        // ShowSnackBar().showSnackbar(context, 'Saving...');
        // } on PlatformException {
        //   barcodeScanRes = "Failed to get platform version.";
      } catch (e) {
        print(e);
      }
    });
  }
}

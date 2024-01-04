import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/components/base_widgets.dart';
import 'package:my_room/components/snack_bar.dart';
import 'package:my_room/constants/enums/date_enum.dart';
import 'package:my_room/models/room_model.dart';
import 'package:my_room/modules/rooms/cubit/room_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class RoomScreen extends StatefulWidget {
  final Function? openDrawer;
  const RoomScreen({super.key, this.openDrawer});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  // TextEditingController roomController = TextEditingController(text: '200');
  // TextEditingController peopleController = TextEditingController(text: '2');

  void showAlertDialog(context) => showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to storage'),
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

  Future<bool> _checkPermission(Permission permission) async {
    var status = await permission.request();
    // print(status);
    if (status != PermissionStatus.granted) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context);
      return false;
    }
    return true;
  }

  Widget _emptyRoom() {
    return Center(
      child: Image.asset(
        'lib/images/room.png',
        width: 300,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<RoomCubit>().roomLoadFileLocal();
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
                controller: context.read<RoomCubit>().state.roomController,
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
                controller: context.read<RoomCubit>().state.peopleController,
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
              onPressed: () async {
                if (context
                        .read<RoomCubit>()
                        .state
                        .roomController
                        .text
                        .isNotEmpty &&
                    int.parse(context
                            .read<RoomCubit>()
                            .state
                            .peopleController
                            .text) >
                        0) {
                  // handleAddRoom();
                  if (await _checkPermission(Permission.storage)) {
                    // ignore: use_build_context_synchronously
                    context.read<RoomCubit>().roomAdd(
                        // ignore: use_build_context_synchronously
                        context.read<RoomCubit>().state.roomController.text,
                        // ignore: use_build_context_synchronously
                        context.read<RoomCubit>().state.peopleController.text,
                        roomStatusE.Available.name);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
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

  Future<void> _dialogDelete(BuildContext context, String title, int index) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notion'),
          content: Text(
            'Are you sure you want to delete room $title?',
            style: const TextStyle(fontSize: 18),
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
                context.read<RoomCubit>().roomRemove(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color renderColorStatus(String type) {
    switch (type) {
      case 'In':
        return Colors.green;
      case 'Out':
        return Colors.red;
      default:
        return Colors.black12;
    }
  }

  List<Widget> renderItemRooms(List<RoomModel> listData) {
    return List.generate(
      listData.length,
      (index) => Stack(children: [
        GestureDetector(
          onLongPress: () => _dialogDelete(
            context,
            listData[index].room,
            index,
          ),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 35),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color:
                    renderColorStatus(listData[index].status).withOpacity(0.3),
                border: Border.all(
                    width: 1,
                    color: renderColorStatus(listData[index].status))),
            child: Column(children: [
              BaseWidgets.instance.rowInfo(
                  'Timer: ',
                  listData[index].timer.isEmpty
                      ? '---'
                      : listData[index].timer),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo('Room: ',
                  listData[index].room.isEmpty ? '---' : listData[index].room),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo('Name: ',
                  listData[index].name.isEmpty ? '---' : listData[index].name),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance
                  .rowInfo('Max People: ', listData[index].people),
              const SizedBox(
                height: 5,
              ),
            ]),
          ),
        ),
        (Positioned(
          bottom: 10,
          right: 8,
          child: listData[index].status == roomStatusE.Out.name
              ? GestureDetector(
                  onTap: () => {
                    context.read<RoomCubit>().roomUpdate('', '',
                        roomStatusE.Available.name, listData[index].room)
                  },
                  child: const Icon(
                    Icons.cleaning_services_outlined,
                    size: 20,
                  ),
                )
              : const SizedBox(),
        )),
        Positioned(
            right: 8,
            top: 8,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text(
                    (listData[index].status.isEmpty
                        ? '---'
                        : listData[index].status),
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
              onTap: () => widget.openDrawer!(),
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
        body: BlocBuilder<RoomCubit, RoomState>(builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return state.listRoom.isEmpty
                ? _emptyRoom()
                : GridView.count(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    children: renderItemRooms(state.listRoom));
          }
        }));
  }
}

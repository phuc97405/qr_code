import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_room/components/base_widgets.dart';
import 'package:my_room/constants/enums/date_enum.dart';
import 'package:my_room/extensions/context_extensions.dart';
import 'package:my_room/extensions/date_extensions.dart';
import 'package:my_room/models/info_model.dart';
import 'package:my_room/models/room_model.dart';
import 'package:my_room/modules/home/bloc/home_bloc.dart';
import 'package:my_room/modules/rooms/cubit/room_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final Function openDrawer;
  const HomeScreen({super.key, required this.openDrawer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DateTime> dateHistory = [];
  late int indexFilterDate = 0;
  final _scrollController = ScrollController();
  late List<String> listRoom =
      context.read<RoomCubit>().state.listRoom.map((e) => e.room).toList();
  // late final roomList = context.read<RoomBloc>().add(RoomLoadData());

  void loadMoreWhenScrollFilter() {
    final List<DateTime> dateNew = List<DateTime>.generate(
        31,
        (i) => DateTime.utc(
              dateHistory.last.year,
              dateHistory.last.month,
              dateHistory.last.day,
            ).subtract(Duration(days: i + 1)));
    setState(() {
      dateHistory.addAll(dateNew);
    });
  }

  void showAlertDialog(context) => showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to camera'),
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
    if (status != PermissionStatus.granted) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context);
      return false;
    }
    return true;
  }

  void getDataInitial() async {
    // ignore: unrelated_type_equality_checks
    if (Permission.camera.status == PermissionStatus.granted) {
      // ignore: use_build_context_synchronously
      context.read<HomeBloc>().add(HomeLoadData());
    }
  }

  @override
  void initState() {
    super.initState();
    getDataInitial();
    dateHistory = List<DateTime>.generate(
        30,
        (i) => DateTime.utc(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ).subtract(Duration(days: i)));
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
                context.read<HomeBloc>().add(HomeRemoverItem(index));
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
        ));
  }

  Future showBottomSheet(InfoModel user) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          print(user.createAt);
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
                      viewButton(
                          Icons.timelapse_sharp,
                          DateTime.now()
                              .aboutHour(user.updateAt, user.createAt),
                          // '${(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(user.createAt))).inMinutes / 60).toStringAsFixed(1)}H',
                          'Timer'),
                      viewButton(Icons.numbers,
                          user.room.isEmpty ? '---' : user.room, 'Room'),
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
                      BaseWidgets.instance.rowInfo('CheckIn: ',
                          DateTime.now().toDateFormat(user.createAt)),
                      // DateFormat('hh:mm dd/MM/yyyy').format(
                      //     DateTime.fromMillisecondsSinceEpoch(
                      //         int.parse(user.createAt)))
                      // ),
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

  List<Widget> _infoUser(List<InfoModel> users) {
    return List.generate(
        users.length,
        (index) => GestureDetector(
              onLongPress: () => _dialogDelete(context, index),
              onTap: () {
                showBottomSheet(users[index]);
              },
              child: Stack(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: users[index].isCheckIn
                          ? Colors.green[100]
                          : Colors.red[100],
                      border: Border.all(
                          width: 1,
                          color: (users[index].isCheckIn
                              ? Colors.green
                              : Colors.red))),
                  child: Column(children: [
                    BaseWidgets.instance.rowInfo(
                      'Room: ',
                      users[index].room.isEmpty ? '---' : users[index].room,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    BaseWidgets.instance.rowInfo('Name: ', users[index].name),
                    const SizedBox(
                      height: 5,
                    ),
                    BaseWidgets.instance
                        .rowInfo('Gender: ', users[index].gender),
                    const SizedBox(
                      height: 5,
                    ),
                    BaseWidgets.instance.rowInfo(
                      'Birth: ',
                      users[index]
                          .birthDay
                          .replaceRange(2, 2, '-')
                          .replaceRange(5, 5, '-'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(DateTime.now().toDateFormat(users[index].createAt),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300)),
                    const SizedBox(
                      height: 5,
                    ),
                  ]),
                ),
                Positioned(
                    right: 8,
                    bottom: 0,
                    child: BlocBuilder<RoomCubit, RoomState>(
                      builder: (context, state) {
                        if (state.listRoom.any((element) =>
                                element.status == roomStatusE.Available.name) &&
                            users[index].room.isEmpty) {
                          return DropdownButton<String>(
                              icon: const Icon(
                                Icons.add_home_outlined,
                                size: 20,
                              ),
                              underline: const SizedBox(),
                              items: state.listRoom
                                  .where((element) =>
                                      element.status ==
                                      roomStatusE.Available.name)
                                  .toList()
                                  .map((RoomModel value) {
                                return DropdownMenuItem<String>(
                                  value: value.room,
                                  child: Text(value.room),
                                );
                              }).toList(),
                              onChanged: (room) async {
                                context.read<HomeBloc>().add(
                                    HomeAddRoomToUser(users[index].id, room!));
                                if (await _checkPermission(
                                    Permission.storage)) {
                                  // ignore: use_build_context_synchronously
                                  context.read<RoomCubit>().roomUpdate(
                                      '',
                                      users[index].name,
                                      users[index].isCheckIn
                                          ? roomStatusE.In.name
                                          : roomStatusE.Out.name,
                                      room);
                                }
                              });
                        } else {
                          return const SizedBox();
                        }
                      },
                    )),
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
                          (users[index].isCheckIn ? 'IN' : "OUT"),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: (users[index].isCheckIn
                                  ? Colors.green
                                  : Colors.red)),
                        ))),
              ]),
            ));
  }

  void handleFilter(int index) {
    setState(() {
      indexFilterDate = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 30,
                )),
          ),
        ],
        title: const Text(
          "My Room",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scanQr',
        tooltip: 'scan', // used by assistive technologies
        onPressed: () async {
          if (await _checkPermission(Permission.camera)) {
            // ignore: use_build_context_synchronously
            context.read<HomeBloc>().add(const HomeScanQR());
          }
          ;
        },
        // _scanQRNormal,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.qr_code,
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            SizedBox(
              height: 65,
              width: double.infinity,
              child: NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    loadMoreWhenScrollFilter();
                  }
                  return true;
                },
                child: ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemExtent: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    reverse: true,
                    children: List.generate(
                        dateHistory.length,
                        (index) => GestureDetector(
                              onTap: () => handleFilter(index),
                              child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: index == indexFilterDate
                                          ? Colors.green
                                          : Colors.grey.withOpacity(0.3),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${DateTime.parse(dateHistory[index].toString()).day}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        WeekdayE
                                            .values[DateTime.parse(
                                                        dateHistory[index]
                                                            .toString())
                                                    .weekday -
                                                1]
                                            .name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  )),
                            )).toList()),
              ),
            ),
            Flexible(
                child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: BlocBuilder<HomeBloc, HomeState>(

                  // buildWhen: (previous, current) =>
                  //     previous.dateHistory != previous.dateHistory,
                  builder: (context, state) {
                if (state is HomeAddRoomToUser) {
                  context.read<RoomCubit>().updateAllRoom(state.listUsers);
                }
                return state.listUsers
                        .where((element) => DateTime.now().isSameDate(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(element.createAt)),
                            dateHistory[indexFilterDate]))
                        .isEmpty
                    ? _emptyWidget()
                    : GridView.count(
                        padding: const EdgeInsets.all(5),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 2,
                        children: _infoUser(state.listUsers
                            .where((element) => DateTime.now().isSameDate(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(element.createAt)),
                                dateHistory[indexFilterDate]))
                            .toList()));
              }),
            )),
          ],
        ),
      ),
    );
  }
}

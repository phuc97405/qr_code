import 'package:flutter/material.dart';
import 'package:my_room/components/base_widgets.dart';
import 'package:my_room/models/info_model.dart';

class UserDetail extends StatefulWidget {
  final InfoModel user;
  const UserDetail({required this.user});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  Widget viewButton(IconData icon, String value) {
    return SizedBox(
      width: 100,
      child: ListTile(
          tileColor: Colors.grey,
          leading: Icon(
            icon,
            size: 30,
            color: Colors.grey,
          ),
          title: Text(
            value,
            style: const TextStyle(color: Colors.red),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            // Text('asdaas'), Text('asdas')
            // viewButton(Icons.timelapse_sharp, '2H'),
            // viewButton(Icons.numbers, '202'),
          ]),
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color:
                    widget.user.isCheckIn ? Colors.green[100] : Colors.red[100],
                border: Border.all(
                    width: 2,
                    color:
                        (widget.user.isCheckIn ? Colors.green : Colors.red))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo('Tên: ', widget.user.name),
              //  BaseWidgets(('Tên: ', info[index].name),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo(
                'Ngày Sinh: ',
                widget.user.birthDay
                    .replaceRange(2, 2, '-')
                    .replaceRange(5, 5, '-'),
              ),
              BaseWidgets.instance.rowInfo('Giới Tính: ', widget.user.gender),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo(
                  'Ngày Cấp: ',
                  widget.user.createdDate
                      .replaceRange(2, 2, '-')
                      .replaceRange(5, 5, '-')),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo('CCCD/CMT: ', widget.user.cccd),
              const SizedBox(
                height: 5,
              ),
              BaseWidgets.instance.rowInfo('Thường trú: ', widget.user.address),
            ]),
          ),
        ]),
      ),
    );
  }
}

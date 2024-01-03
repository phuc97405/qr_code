import 'package:equatable/equatable.dart';

final class RoomModel extends Equatable {
  String id;
  String status;
  String timer;
  String name;
  String room;
  String people;

  RoomModel(
      {required this.id,
      required this.name,
      required this.people,
      required this.room,
      required this.status,
      required this.timer});

  @override
  List<Object> get props => [id, name, people, room, status, timer];
}

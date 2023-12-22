class RoomModel {
  String id;
  String status;
  String timer;
  String cccd;
  String name;
  String room;
  String people;

  RoomModel(
      {required this.id,
      required this.cccd,
      required this.name,
      required this.people,
      required this.room,
      required this.status,
      required this.timer});
}

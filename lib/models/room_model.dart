class RoomModel {
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
}

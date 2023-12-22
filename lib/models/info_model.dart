class InfoModel {
  String id;
  String cccd;
  String name;
  String birthDay;
  String gender;
  String address;
  String createdDate;
  String createAt;
  bool isCheckIn;
  String updateAt;
  String room;
  InfoModel(
      {required this.isCheckIn,
      required this.id,
      required this.cccd,
      required this.name,
      required this.birthDay,
      required this.address,
      required this.createdDate,
      required this.createAt,
      required this.gender,
      required this.updateAt,
      required this.room});
}

class InfoModel {
  String id;
  String cccd;
  String name;
  String birthDay;
  String gender;
  String address;
  String createdDate;
  String createAdd;
  bool isCheckIn;
  String updateAt;
  InfoModel(
      {required this.isCheckIn,
      required this.id,
      required this.cccd,
      required this.name,
      required this.birthDay,
      required this.address,
      required this.createdDate,
      required this.createAdd,
      required this.gender,
      required this.updateAt});
}

part of 'room_cubit.dart';

class RoomState extends Equatable {
  final List<RoomModel> listRoom;

  TextEditingController roomController = TextEditingController();
  TextEditingController peopleController = TextEditingController(text: '2');

  RoomState({this.listRoom = const []});

  @override
  bool operator ==(covariant RoomState other) => other.listRoom == listRoom;

  @override
  int get hashCode => super.hashCode;
  @override
  List<Object> get props => [listRoom];
}

class RoomInitial extends RoomState {}

// class RoomSetData extends RoomState {
//   final List<RoomModel> listRoom;

//   const RoomSetData(this.listRoom);
// }

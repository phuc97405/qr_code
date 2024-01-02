part of 'room_cubit.dart';

class RoomState extends Equatable {
  final List<RoomModel> listRoom;
  bool isLoading;

  TextEditingController roomController = TextEditingController();
  TextEditingController peopleController = TextEditingController(text: '2');

  RoomState({this.listRoom = const [], this.isLoading = false});

  RoomState copyWith({List<RoomModel>? listRoom, bool? isLoading}) {
    return RoomState(
        listRoom: listRoom ?? this.listRoom,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(covariant RoomState other) => other.listRoom == listRoom;

  @override
  int get hashCode => super.hashCode;
  @override
  List<Object> get props => [listRoom, isLoading];
}

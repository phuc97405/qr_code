part of 'room_cubit.dart';

final class RoomState extends Equatable {
  final List<RoomModel> listRoom;
  final bool isLoading;

  TextEditingController roomController = TextEditingController();
  TextEditingController peopleController = TextEditingController(text: '2');

  RoomState._({this.listRoom = const [], this.isLoading = false});

  RoomState copyWith({List<RoomModel>? listRoom, bool? isLoading}) {
    return RoomState._(
        listRoom: listRoom ?? this.listRoom,
        isLoading: isLoading ?? this.isLoading);
  }

  RoomState.initial() : this._();

  @override
  List<Object> get props => [listRoom, isLoading];
}

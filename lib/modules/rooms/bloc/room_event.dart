part of 'room_bloc.dart';

sealed class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

class RoomLoadData extends RoomEvent {}

class RoomAdd extends RoomEvent {
  final String roomCode;
  final String roomPeople;
  final String roomStatus;
  const RoomAdd(
      {required this.roomCode,
      required this.roomPeople,
      required this.roomStatus});
}

class RoomDeleteItem extends RoomEvent {
  int index;
  RoomDeleteItem({required this.index});
}

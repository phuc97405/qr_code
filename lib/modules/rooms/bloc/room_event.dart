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

class RoomDelete extends RoomEvent {
  final int index;
  const RoomDelete({required this.index});
}

class RoomUpdate extends RoomEvent {
  final String timer;
  final String name;
  final String status;
  final String room;

  const RoomUpdate(this.timer, this.name, this.status, this.room);
}

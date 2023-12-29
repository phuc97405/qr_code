part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// class HomeInitial extends HomeEvent {}

class HomeLoadData extends HomeEvent {}

class HomeScanQR extends HomeEvent {
  const HomeScanQR();
}

class HomeRemoverItem extends HomeEvent {
  final int indexItemRemove;

  const HomeRemoverItem(this.indexItemRemove);
}

class HomeAddRoomToUser extends HomeEvent {
  final String id;
  final String room;

  const HomeAddRoomToUser(this.id, this.room);
}

class HomeSearchNameOfUser extends HomeEvent {
  final String keyword;

  const HomeSearchNameOfUser(this.keyword);
}

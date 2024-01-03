part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// class HomeInitial extends HomeEvent {}

final class HomeLoadData extends HomeEvent {}

final class HomeScanQR extends HomeEvent {
  const HomeScanQR();
}

final class HomeRemoverItem extends HomeEvent {
  final int indexItemRemove;

  const HomeRemoverItem(this.indexItemRemove);
}

final class HomeAddRoomToUser extends HomeEvent {
  final String id;
  final String room;

  const HomeAddRoomToUser(this.id, this.room);
}

final class HomeSearchNameOfUser extends HomeEvent {
  final String keyword;

  const HomeSearchNameOfUser(this.keyword);
}

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

final class HomeSetIndexFilterDate extends HomeEvent {
  final int? index;

  const HomeSetIndexFilterDate(this.index);
}

final class HomeSetListDate extends HomeEvent {
  final List<DateTime> listDate;

  const HomeSetListDate(this.listDate);
}

final class HomeLoadMoreDate extends HomeEvent {}

final class HomeSetIsShowSearch extends HomeEvent {
  final bool isShowSearch;

  const HomeSetIsShowSearch(this.isShowSearch);
}

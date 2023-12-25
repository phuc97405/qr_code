part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomeLoadData extends HomeEvent {}

class HomeScanQR extends HomeEvent {}

class HomeRemoverItem extends HomeEvent {
  final int indexItemRemove;

  const HomeRemoverItem(this.indexItemRemove);
}

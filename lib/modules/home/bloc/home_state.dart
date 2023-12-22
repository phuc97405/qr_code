part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class GetDataFromCsv extends HomeState {
  List<DateTime> dateHistory = [];
  GetDataFromCsv({required this.dateHistory});
}

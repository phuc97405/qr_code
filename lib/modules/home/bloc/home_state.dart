part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<InfoModel> dateHistory;

  const HomeState._({required this.dateHistory});

  const HomeState.initial(this.dateHistory);
  const HomeState.loadData(List<InfoModel> data) : this._(dateHistory: data);

  @override
  List<Object?> get props => [dateHistory];
}

// class HomeInitial extends HomeState {}

// class DataUser extends HomeState {
//   List<DateTime> dateHistory = [];
//   DataUser({required this.dateHistory});

//   @override
//   List<Object> get props => [dateHistory];
// }

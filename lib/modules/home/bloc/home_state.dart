part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<InfoModel> dateHistory;
  const HomeState._({
    required this.dateHistory,
  });

  const HomeState.initial(this.dateHistory);

  const HomeState.loadData(List<InfoModel> data)
      : this._(
          dateHistory: data,
        );

  @override
  bool operator ==(covariant HomeState other) =>
      other.dateHistory == dateHistory;

  @override
  int get hashCode => super.hashCode;

  @override
  List<Object?> get props => [dateHistory];
}


// class HomeSetData extends HomeState {
//   final List<InfoModel> data;

//   const HomeSetData(this.data) : super(dateHistory: data);
// }

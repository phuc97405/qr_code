part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<InfoModel> listUsers;

  final TextEditingController searchController = TextEditingController();
  final int indexFilterDate = 0;

  HomeState._({
    required this.listUsers,
  });

  HomeState.initial(this.listUsers);

  HomeState.setData(List<InfoModel> data)
      : this._(
          listUsers: data,
        );

  @override
  bool operator ==(covariant HomeState other) => other.listUsers == listUsers;

  @override
  int get hashCode => super.hashCode;

  // @override
  // List<InfoModel> get usersList => listUsers;

  @override
  List<Object?> get props => [];
}


// class HomeInitial extends HomeState {}

// class HomeLoading extends HomeState {}

// class HomeSetData extends HomeState {
//   final List<InfoModel> listUsers;
//   HomeSetData(this.listUsers);

//   @override
//   List<Object?> get props => [listUsers];
// }

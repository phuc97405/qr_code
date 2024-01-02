part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<InfoModel>? listUsers;
  final TextEditingController searchController = TextEditingController();
  int indexFilterDate;
  bool isLoading;

  HomeState._(
      {this.listUsers = const [],
      this.isLoading = true,
      this.indexFilterDate = 0});

  HomeState copyWith(
      {List<InfoModel>? listUsers, int? indexFilterDate, bool? isLoading}) {
    return HomeState._(
        listUsers: listUsers ?? this.listUsers,
        indexFilterDate: indexFilterDate ?? this.indexFilterDate,
        isLoading: isLoading ?? this.isLoading);
  }

  HomeState.initial() : this._();

  HomeState.setData(List<InfoModel> data)
      : this._(listUsers: data, isLoading: false);

  HomeState.setLoading(bool value) : this._(isLoading: false);

  @override
  bool operator ==(covariant HomeState other) => other.listUsers == listUsers;

  @override
  int get hashCode => super.hashCode;

  @override
  List<Object?> get props => [listUsers, isLoading, indexFilterDate];
}

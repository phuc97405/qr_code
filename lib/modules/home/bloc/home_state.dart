part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

extension HomeStatusX on HomeStatus {
  bool get isInitial => this == HomeStatus.initial;
  bool get isLoading => this == HomeStatus.loading;
  bool get isSuccess => this == HomeStatus.success;
  bool get isFailure => this == HomeStatus.failure;
}

final class HomeState extends Equatable {
  final List<InfoModel> listUsers;
  final HomeStatus status;
  final TextEditingController searchController = TextEditingController();
  int indexFilterDate;
  // bool isLoading;

  HomeState._(
      {this.status = HomeStatus.initial,
      this.listUsers = const [],
      // this.isLoading = true,
      this.indexFilterDate = 0});

  HomeState copyWith(
      {HomeStatus? status,
      List<InfoModel>? listUsers,
      int? indexFilterDate,
      bool? isLoading}) {
    return HomeState._(
      status: status ?? this.status,
      listUsers: listUsers ?? this.listUsers,
      indexFilterDate: indexFilterDate ?? this.indexFilterDate,
      // isLoading: isLoading ?? this.isLoading
    );
  }

  HomeState.initial() : this._();

  // HomeState.setData(List<InfoModel> data)
  //     : this._(listUsers: data, isLoading: false);

  @override
  String toString() {
    return '''HomeState { listUsers: ${listUsers.length}, status: $status, indexFilterDate: $indexFilterDate }''';
  }

  @override
  List<Object> get props => [listUsers, indexFilterDate, status];
}

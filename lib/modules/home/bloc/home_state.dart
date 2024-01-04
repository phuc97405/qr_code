part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure, checkout }

extension HomeStatusX on HomeStatus {
  bool get isInitial => this == HomeStatus.initial;
  bool get isLoading => this == HomeStatus.loading;
  bool get isSuccess => this == HomeStatus.success;
  bool get isFailure => this == HomeStatus.failure;
  bool get isCheckOut => this == HomeStatus.checkout;
}

final class HomeState extends Equatable {
  final List<InfoModel> listUsers;
  final HomeStatus status;
  final TextEditingController searchController = TextEditingController();
  final int indexFilterDate;
  final int? indexRoomCheckout;
  // bool isLoading;

  HomeState._(
      {this.status = HomeStatus.initial,
      this.listUsers = const [],
      // this.isLoading = true,
      this.indexFilterDate = 0,
      this.indexRoomCheckout = -1});

  HomeState copyWith(
      {HomeStatus? status,
      List<InfoModel>? listUsers,
      int? indexFilterDate,
      bool? isLoading,
      int? indexRoomCheckout}) {
    return HomeState._(
        status: status ?? this.status,
        listUsers: listUsers ?? this.listUsers,
        indexFilterDate: indexFilterDate ?? this.indexFilterDate,
        indexRoomCheckout: indexRoomCheckout ?? this.indexRoomCheckout);
  }

  HomeState.initial() : this._();

  @override
  String toString() {
    return '''HomeState { listUsers: ${listUsers.length}, status: $status, indexFilterDate: $indexFilterDate }''';
  }

  @override
  List<Object> get props => [listUsers, indexFilterDate, status];
}

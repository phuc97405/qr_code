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
  final int indexFilterDate;
  final int indexRoomCheckout;
  final List<DateTime> listDate;
  final bool isShowInputSearch;

  const HomeState._(
      {this.status = HomeStatus.initial,
      this.listUsers = const [],
      this.indexFilterDate = 0,
      this.indexRoomCheckout = -1,
      this.listDate = const [],
      this.isShowInputSearch = false});

  HomeState copyWith({
    HomeStatus? status,
    List<InfoModel>? listUsers,
    int? indexFilterDate,
    bool? isLoading,
    int? indexRoomCheckout,
    List<DateTime>? listDate,
    bool? isShowInputSearch,
  }) {
    return HomeState._(
      status: status ?? this.status,
      listUsers: listUsers ?? this.listUsers,
      indexFilterDate: indexFilterDate ?? this.indexFilterDate,
      indexRoomCheckout: indexRoomCheckout ?? this.indexRoomCheckout,
      listDate: listDate ?? this.listDate,
      isShowInputSearch: isShowInputSearch ?? this.isShowInputSearch,
    );
  }

  const HomeState.initial() : this._();

  @override
  String toString() {
    return '''HomeState { listUsers: ${listUsers.length}, status: $status, indexFilterDate: $indexFilterDate ,listDate: $listDate}''';
  }

  @override
  List<Object> get props => [
        listUsers,
        indexFilterDate,
        status,
        indexRoomCheckout,
        listDate,
        isShowInputSearch,
      ];
}

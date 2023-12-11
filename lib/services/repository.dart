import 'package:my_room/services/api_provider.dart';

class Repository {
  final MyApiProvide myApiProvider;
  Repository(this.myApiProvider);

  Future<void> pushDataToTele(String param) async {
    final res = await myApiProvider.post('/uxFagE1N1qdsJYg6Pt8PVo7p', param);
    print('pushDataToTele$res');
    // return userFromJson(res.toString());
  }
}

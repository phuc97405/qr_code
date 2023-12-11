import 'dart:convert';
import 'package:dio/dio.dart';

class MyApiProvide {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: "https://pushmore.io/webhook/",
      connectTimeout: const Duration(seconds: 6000),
      receiveTimeout: const Duration(seconds: 6000),
      responseType: ResponseType.json,
      contentType: 'application/json'));

  MyApiProvide() {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (option, handler) async {
      option.headers['Accept'] = 'application/json';
      // String? token = _getStorage.read(GetStorageKey.accessToken);
      // option.headers['Authorization'] = 'Bearer $token';
      return handler.next(option);
    }, onError: (error, handle) async {
      if (error.response?.statusCode == 401) {
        //token is authorized
        // final newAccessToken = await refreshToken();
        // if (newAccessToken != null) {
        //   _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
        // }
      }
      return handle.next(error);
    }));
  }

  // Future<String?> refreshToken() async {
  //   try {
  //     final refreshToken = _getStorage.read(GetStorageKey.refreshToken);
  //     final response = await _dio.post('/authentication/refresh',
  //         data: {'refreshToken': refreshToken});
  //     final newAccessToken = response.data['accessToken'];
  //     _getStorage.write(GetStorageKey.accessToken, newAccessToken);
  //     return newAccessToken;
  //   } catch (exception) {
  //     _getStorage.erase();
  //     //Get.offAllNamed(Routes.login);
  //   }
  //   return null;
  // }

  Future<Response<T>> post<T, K>(
    String url,
    K body,
  ) async {
    try {
      final res = await _dio.post<T>(
        url,
        data: jsonEncode(body),
      );
      return res;
    } on DioException catch (err) {
      if (err.response?.statusCode == 401) {
        return Future.error("Invalid Credential");
      } else {
        return Future.error(err.response.toString());
      }
    } catch (exception) {
      return Future.error(exception.toString());
    }
  }

  Future<Response<T>> get<T, K>(String url,
      [Map<String, dynamic>? headers]) async {
    try {
      final res = await _dio.get<T>(url, queryParameters: headers);
      return res;
    } on DioException catch (err) {
      if (err.response?.statusCode == 401) {
        return Future.error("Invalid Credential");
      } else {
        return Future.error("Internal Server Error");
      }
    } catch (exception) {
      return Future.error(exception.toString());
    }
  }

  Future<Response<T>> put<T, K>(String url, K body,
      [Map<String, dynamic>? headers]) async {
    try {
      final res = await _dio.put<T>(url, data: body, queryParameters: headers);
      return res;
    } on DioException catch (err) {
      if (err.response?.statusCode == 401) {
        return Future.error("Invalid Credential");
      } else {
        return Future.error("Internal Server Error");
      }
    } catch (exception) {
      return Future.error(exception.toString());
    }
  }
}

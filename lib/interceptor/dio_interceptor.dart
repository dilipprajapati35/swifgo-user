import 'package:dio/dio.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';

class DioInterceptor extends Interceptor {
  final _secureStorage = MySecureStorage();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll({
      'Content-Type': 'application/json',
    });

    final token = await _secureStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}

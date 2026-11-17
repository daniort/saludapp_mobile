import 'package:dio/dio.dart';
import 'package:saludap/utils/app_config.dart';
import 'package:saludap/utils/app_durations.dart';

class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppDurations.networkTimeout,
              receiveTimeout: AppDurations.networkTimeout,
              sendTimeout: AppDurations.networkTimeout,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Dio get dio => _dio;

  void setBearerToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearBearerToken() {
    _dio.options.headers.remove('Authorization');
  }

  void close() => _dio.close(force: true);
}

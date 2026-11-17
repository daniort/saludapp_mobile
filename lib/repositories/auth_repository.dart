import 'package:dio/dio.dart';
import 'package:saludap/models/auth_model.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/api_exception.dart';
import 'package:saludap/utils/app_endpoints.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    return _authenticate(
      AppEndpoints.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<AuthModel> register({
    required String email,
    required String password,
    required String givenNames,
    String? paternalSurname,
    String? maternalSurname,
    DateTime? birthDate,
  }) async {
    return _authenticate(
      AppEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'givenNames': givenNames,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
        'birthDate': birthDate == null ? null : _dateOnly(birthDate),
      },
    );
  }

  Future<AuthModel> loginWithGoogle(String googleIdToken) async {
    return _authenticate(
      AppEndpoints.googleLogin,
      data: {'googleIdToken': googleIdToken},
    );
  }

  Future<AuthTokensModel> refresh(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        AppEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final tokens = response.data?['data']?['tokens'];
      if (tokens is! Map) throw const FormatException();
      return AuthTokensModel.fromJson(Map<String, dynamic>.from(tokens));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La sesión renovada no es válida.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post<void>(AppEndpoints.logout);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  void activateSession(AuthModel auth) {
    _apiClient.setBearerToken(auth.tokens.idToken);
  }

  void clearSession() => _apiClient.clearBearerToken();

  Future<AuthModel> _authenticate(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        endpoint,
        data: data,
      );
      final body = response.data;
      if (body == null) throw const FormatException();

      final auth = AuthModel.fromJson(body);
      activateSession(auth);
      return auth;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La respuesta de autenticación no es válida.');
    }
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

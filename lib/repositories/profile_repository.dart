import 'package:dio/dio.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/api_exception.dart';
import 'package:saludap/utils/app_endpoints.dart';

class ProfileRepository {
  const ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProfileModel>> listProfiles() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        AppEndpoints.profiles,
      );
      final profiles = response.data?['data']?['profiles'];
      if (profiles is! List) throw const FormatException();

      return profiles
          .map(
            (profile) => ProfileModel.fromJson(
              Map<String, dynamic>.from(profile as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La respuesta de perfiles no es válida.');
    }
  }
}

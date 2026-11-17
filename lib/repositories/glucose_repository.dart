import 'package:dio/dio.dart';
import 'package:saludap/models/glucose_reading_model.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/api_exception.dart';
import 'package:saludap/utils/app_endpoints.dart';

class GlucoseRepository {
  const GlucoseRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<GlucoseReadingModel>> listReadings(String profileId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        AppEndpoints.glucoseReadings,
        queryParameters: {'profileId': profileId, 'limit': 100},
      );
      final readings = response.data?['data']?['readings'];
      if (readings is! List) throw const FormatException();

      return readings
          .map(
            (reading) => GlucoseReadingModel.fromJson(
              Map<String, dynamic>.from(reading as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La respuesta de glucosa no es válida.');
    }
  }

  Future<GlucoseReadingModel> createReading({
    required String profileId,
    required double value,
    required GlucoseTakenContext takenContext,
    required DateTime takenAt,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        AppEndpoints.glucoseReadings,
        data: {
          'profileId': profileId,
          'value': value,
          'takenContext': takenContext.apiValue,
          'notes': notes,
          'takenAt': takenAt.toUtc().toIso8601String(),
        },
      );
      final reading = response.data?['data']?['reading'];
      if (reading is! Map) throw const FormatException();
      return GlucoseReadingModel.fromJson(Map<String, dynamic>.from(reading));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La lectura guardada no es válida.');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:saludap/models/blood_pressure_reading_model.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/api_exception.dart';
import 'package:saludap/utils/app_endpoints.dart';

class BloodPressureRepository {
  const BloodPressureRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BloodPressureReadingModel>> listReadings(String profileId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        AppEndpoints.bloodPressureReadings,
        queryParameters: {'profileId': profileId, 'limit': 100},
      );
      final readings = response.data?['data']?['readings'];
      if (readings is! List) throw const FormatException();

      return readings
          .map(
            (reading) => BloodPressureReadingModel.fromJson(
              Map<String, dynamic>.from(reading as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La respuesta de presión no es válida.');
    }
  }

  Future<BloodPressureReadingModel> createReading({
    required String profileId,
    required int systolic,
    required int diastolic,
    required DateTime takenAt,
    int? pulse,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        AppEndpoints.bloodPressureReadings,
        data: {
          'profileId': profileId,
          'systolic': systolic,
          'diastolic': diastolic,
          'pulse': pulse,
          'notes': notes,
          'takenAt': takenAt.toUtc().toIso8601String(),
        },
      );
      final reading = response.data?['data']?['reading'];
      if (reading is! Map) throw const FormatException();
      return BloodPressureReadingModel.fromJson(
        Map<String, dynamic>.from(reading),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException('La lectura guardada no es válida.');
    }
  }
}

import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  factory ApiException.fromDio(DioException error) {
    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null) return ApiException(serverMessage);

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ApiException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      ),
      DioExceptionType.connectionError => const ApiException(
        'No fue posible conectar con el servidor.',
      ),
      _ => const ApiException('No fue posible completar la operación.'),
    };
  }

  static String? _serverMessage(Object? data) {
    if (data is! Map) return null;

    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error is Map) {
      final nestedMessage = error['message'];
      if (nestedMessage is String && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }

    return null;
  }

  @override
  String toString() => message;
}

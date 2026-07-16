import 'package:dio/dio.dart';

/// Human-readable message from any repository failure: the server's
/// validation message when present, otherwise the mapped error type.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (error.error != null) {
      return error.error.toString();
    }

    return 'The request failed. Please try again.';
  }

  return error.toString();
}

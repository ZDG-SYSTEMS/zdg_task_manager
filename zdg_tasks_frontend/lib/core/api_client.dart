import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'env.dart';
import 'errors.dart';
import 'token_store.dart';

part 'api_client.g.dart';

/// The single dio instance used by every repository. Widgets never call
/// dio directly. The interceptor attaches the Sanctum bearer token and
/// maps transport failures onto the shared error types.
@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenStoreProvider).read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Centralised mapping so repositories throw AppException
        // subtypes. Full auth handling lands with Phase 2.
        final status = error.response?.statusCode;
        if (status == 401) {
          handler.reject(
            error.copyWith(
              error: const UnauthenticatedException('Session expired'),
            ),
          );
          return;
        }
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          handler.reject(
            error.copyWith(
              error: const NetworkException('Could not reach the server'),
            ),
          );
          return;
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

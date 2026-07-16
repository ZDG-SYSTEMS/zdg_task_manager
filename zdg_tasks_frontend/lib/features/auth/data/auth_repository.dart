import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/company.dart';
import '../../../shared/models/user.dart';
import 'auth_session.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
      'device_name': 'zdg-tasks-app',
    });

    return AuthSession(
      token: response.data['token'] as String,
      user: User.fromJson(response.data['user'] as Map<String, dynamic>),
    );
  }

  /// Self-registration: no role; the account awaits activation.
  Future<void> register(Map<String, dynamic> payload) async {
    await _dio.post('/auth/register', data: payload);
  }

  Future<User> me() async {
    final response = await _dio.get('/auth/me');

    return User.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<User> updateProfile(Map<String, dynamic> payload) async {
    final response = await _dio.patch('/auth/me', data: payload);

    return User.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<List<Company>> companies() async {
    final response = await _dio.get('/companies');

    return (response.data['companies'] as List)
        .map((json) => Company.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository(ref.watch(apiClientProvider));

@riverpod
Future<List<Company>> companies(Ref ref) => ref.watch(authRepositoryProvider).companies();

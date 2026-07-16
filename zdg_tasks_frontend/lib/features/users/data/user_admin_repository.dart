import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/user.dart';

part 'user_admin_repository.g.dart';

/// Technical-only account management: listing accounts and assigning
/// roles, which activates pending registrations.
class UserAdminRepository {
  UserAdminRepository(this._dio);

  final Dio _dio;

  Future<List<User>> list() async {
    final response = await _dio.get('/users');

    return (response.data['data'] as List)
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<User> update(int id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/users/$id', data: payload);

    return User.fromJson(response.data['user'] as Map<String, dynamic>);
  }
}

@riverpod
UserAdminRepository userAdminRepository(Ref ref) =>
    UserAdminRepository(ref.watch(apiClientProvider));

@riverpod
Future<List<User>> userList(Ref ref) => ref.watch(userAdminRepositoryProvider).list();

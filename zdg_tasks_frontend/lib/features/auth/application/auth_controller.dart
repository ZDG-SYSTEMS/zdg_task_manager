import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/push_service.dart';
import '../../../core/token_store.dart';
import '../data/auth_repository.dart';
import '../data/auth_session.dart';

part 'auth_controller.g.dart';

/// Holds the authenticated session for the whole app. The router's
/// guard and every permission check read from here.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthSession?> build() async {
    // Bootstrap: a stored token is validated against /auth/me so a
    // revoked or expired token can never fake a session. Any storage
    // failure (e.g. platform without secure storage) means signed out;
    // throwing here would make Riverpod retry the provider forever.
    final String? token;
    try {
      token = await ref.read(tokenStoreProvider).read();
    } catch (_) {
      return null;
    }
    if (token == null) return null;

    try {
      final user = await ref.read(authRepositoryProvider).me();

      return AuthSession(token: token, user: user);
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();

      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(tokenStoreProvider).write(session.token);
      // Best-effort push registration; never blocks sign-in.
      ref.read(pushServiceProvider).registerDevice();

      return session;
    });
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await ref.read(pushServiceProvider).unregisterDevice();
    try {
      await repository.logout();
    } catch (_) {
      // Token may already be revoked; local sign-out proceeds anyway.
    }
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }

  /// Self-edit of name, email, or password.
  Future<void> updateProfile(Map<String, dynamic> payload) async {
    final session = state.value;
    if (session == null) return;

    final user = await ref.read(authRepositoryProvider).updateProfile(payload);
    state = AsyncData(session.copyWith(user: user));
  }
}

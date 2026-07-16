import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/user.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// The signed-in user's session: the Sanctum token plus the full user
/// record the router and permission mirror read from.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String token,
    required User user,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

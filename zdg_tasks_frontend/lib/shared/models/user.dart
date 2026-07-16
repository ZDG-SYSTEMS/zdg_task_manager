import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';
import 'company.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String code,
    required String name,
    required String email,
    required int companyId,
    Company? company,
    required String department,
    String? branch,
    required String position,
    // Null until technical assigns a role (pending activation).
    Role? role,
    required UserStatus status,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

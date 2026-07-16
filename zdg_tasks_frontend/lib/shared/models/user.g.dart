// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  companyId: (json['company_id'] as num).toInt(),
  company: json['company'] == null
      ? null
      : Company.fromJson(json['company'] as Map<String, dynamic>),
  department: json['department'] as String,
  branch: json['branch'] as String?,
  position: json['position'] as String,
  role: $enumDecodeNullable(_$RoleEnumMap, json['role']),
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'email': instance.email,
  'company_id': instance.companyId,
  'company': instance.company?.toJson(),
  'department': instance.department,
  'branch': instance.branch,
  'position': instance.position,
  'role': _$RoleEnumMap[instance.role],
  'status': _$UserStatusEnumMap[instance.status]!,
};

const _$RoleEnumMap = {
  Role.technical: 'technical',
  Role.director: 'director',
  Role.dof: 'dof',
  Role.companyFinance: 'company_finance',
  Role.deptHead: 'dept_head',
  Role.auditor: 'auditor',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
};

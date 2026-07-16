// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Company _$CompanyFromJson(Map<String, dynamic> json) => _Company(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
};

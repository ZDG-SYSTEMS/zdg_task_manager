// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attachment _$AttachmentFromJson(Map<String, dynamic> json) => _Attachment(
  id: (json['id'] as num).toInt(),
  kind: $enumDecode(_$AttachmentKindEnumMap, json['kind']),
  originalName: json['original_name'] as String,
  mimeType: json['mime_type'] as String,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$AttachmentToJson(_Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$AttachmentKindEnumMap[instance.kind]!,
      'original_name': instance.originalName,
      'mime_type': instance.mimeType,
      'size': instance.size,
    };

const _$AttachmentKindEnumMap = {
  AttachmentKind.quotation: 'quotation',
  AttachmentKind.invoice: 'invoice',
  AttachmentKind.receipt: 'receipt',
};

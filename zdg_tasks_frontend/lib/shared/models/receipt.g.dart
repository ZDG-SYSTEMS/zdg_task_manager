// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toInt(),
  verified: json['verified'] as bool,
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  attachment: json['attachment'] == null
      ? null
      : Attachment.fromJson(json['attachment'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'verified': instance.verified,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'attachment': instance.attachment?.toJson(),
};

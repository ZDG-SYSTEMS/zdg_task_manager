import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required int id,
    // Integer minor units (ngwee).
    required int amount,
    required bool verified,
    DateTime? verifiedAt,
    Attachment? attachment,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}

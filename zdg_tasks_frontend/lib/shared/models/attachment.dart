import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    required int id,
    required AttachmentKind kind,
    required String originalName,
    required String mimeType,
    required int size,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
}

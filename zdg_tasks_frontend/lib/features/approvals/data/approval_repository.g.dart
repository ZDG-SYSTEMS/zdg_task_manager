// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(approvalRepository)
final approvalRepositoryProvider = ApprovalRepositoryProvider._();

final class ApprovalRepositoryProvider
    extends
        $FunctionalProvider<
          ApprovalRepository,
          ApprovalRepository,
          ApprovalRepository
        >
    with $Provider<ApprovalRepository> {
  ApprovalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'approvalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$approvalRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApprovalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApprovalRepository create(Ref ref) {
    return approvalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApprovalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApprovalRepository>(value),
    );
  }
}

String _$approvalRepositoryHash() =>
    r'98873dbba6ada7dc3e096ca614f927a21ddaeff6';

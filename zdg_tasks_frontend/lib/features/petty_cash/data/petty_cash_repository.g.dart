// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petty_cash_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pettyCashRepository)
final pettyCashRepositoryProvider = PettyCashRepositoryProvider._();

final class PettyCashRepositoryProvider
    extends
        $FunctionalProvider<
          PettyCashRepository,
          PettyCashRepository,
          PettyCashRepository
        >
    with $Provider<PettyCashRepository> {
  PettyCashRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pettyCashRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pettyCashRepositoryHash();

  @$internal
  @override
  $ProviderElement<PettyCashRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PettyCashRepository create(Ref ref) {
    return pettyCashRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PettyCashRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PettyCashRepository>(value),
    );
  }
}

String _$pettyCashRepositoryHash() =>
    r'6c5194bf61745dcdb282b12c59a1b718cd57088d';

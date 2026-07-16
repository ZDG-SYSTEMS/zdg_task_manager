// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'35fc3246f662d791da4dd74b7b243027958bee68';

@ProviderFor(companies)
final companiesProvider = CompaniesProvider._();

final class CompaniesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Company>>,
          List<Company>,
          FutureOr<List<Company>>
        >
    with $FutureModifier<List<Company>>, $FutureProvider<List<Company>> {
  CompaniesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Company>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Company>> create(Ref ref) {
    return companies(ref);
  }
}

String _$companiesHash() => r'1cfd4ed7284340f901388c7263f9e64d03af2a27';

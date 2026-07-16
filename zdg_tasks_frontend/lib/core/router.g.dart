// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Declarative routes with role-based redirect guards reading the auth
/// provider. Guards only hide surfaces; the API is the enforcement
/// point for every permission.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// Declarative routes with role-based redirect guards reading the auth
/// provider. Guards only hide surfaces; the API is the enforcement
/// point for every permission.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Declarative routes with role-based redirect guards reading the auth
  /// provider. Guards only hide surfaces; the API is the enforcement
  /// point for every permission.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'47e7869142519ee608a01665382cb0337c5f6542';

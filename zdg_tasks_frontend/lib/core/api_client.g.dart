// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single dio instance used by every repository. Widgets never call
/// dio directly. The interceptor attaches the Sanctum bearer token and
/// maps transport failures onto the shared error types.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// The single dio instance used by every repository. Widgets never call
/// dio directly. The interceptor attaches the Sanctum bearer token and
/// maps transport failures onto the shared error types.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The single dio instance used by every repository. Widgets never call
  /// dio directly. The interceptor attaches the Sanctum bearer token and
  /// maps transport failures onto the shared error types.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiClientHash() => r'537f3c5e0c220e7bcb102f6839e55947391965b0';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userAdminRepository)
final userAdminRepositoryProvider = UserAdminRepositoryProvider._();

final class UserAdminRepositoryProvider
    extends
        $FunctionalProvider<
          UserAdminRepository,
          UserAdminRepository,
          UserAdminRepository
        >
    with $Provider<UserAdminRepository> {
  UserAdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAdminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAdminRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserAdminRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserAdminRepository create(Ref ref) {
    return userAdminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserAdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserAdminRepository>(value),
    );
  }
}

String _$userAdminRepositoryHash() =>
    r'547dbfda34222edfc7ed4bffdd0e0a27aa9ed8ab';

@ProviderFor(userList)
final userListProvider = UserListProvider._();

final class UserListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<User>>,
          List<User>,
          FutureOr<List<User>>
        >
    with $FutureModifier<List<User>>, $FutureProvider<List<User>> {
  UserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userListHash();

  @$internal
  @override
  $FutureProviderElement<List<User>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<User>> create(Ref ref) {
    return userList(ref);
  }
}

String _$userListHash() => r'38de3ce89a3620afa000ced3b62f867c27736596';

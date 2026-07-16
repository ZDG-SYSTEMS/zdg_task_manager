// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'c9113bc3d7e42a4764b5e430e7a41c43a57582ba';

@ProviderFor(notificationList)
final notificationListProvider = NotificationListProvider._();

final class NotificationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          FutureOr<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $FutureProvider<List<AppNotification>> {
  NotificationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationListHash();

  @$internal
  @override
  $FutureProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppNotification>> create(Ref ref) {
    return notificationList(ref);
  }
}

String _$notificationListHash() => r'4cb83e5ef1f76dd02419756da8b48a9a32f23b86';

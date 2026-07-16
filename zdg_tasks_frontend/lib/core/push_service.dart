import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_client.dart';

part 'push_service.g.dart';

/// FCM registration. Push is best-effort everywhere: when Firebase is
/// not configured for the current platform the service quietly does
/// nothing, and email plus in-app records still carry every event.
class PushService {
  PushService(this._dio);

  final Dio _dio;

  static bool _initialized = false;

  /// Called once from main(); safe when Firebase is unconfigured.
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web needs firebase_options.dart from flutterfire configure;
      // skip until that lands.
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (error) {
      debugPrint('Firebase unavailable: $error');
    }
  }

  /// Registers this device's FCM token after sign-in.
  Future<void> registerDevice() async {
    if (!_initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null) return;

      await _dio.post('/device-tokens', data: {
        'token': token,
        'platform': defaultTargetPlatform.name,
      });
    } catch (error) {
      debugPrint('FCM registration skipped: $error');
    }
  }

  /// Detaches the token on sign-out so the next user is not notified.
  Future<void> unregisterDevice() async {
    if (!_initialized) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _dio.delete('/device-tokens', data: {'token': token});
    } catch (error) {
      debugPrint('FCM unregistration skipped: $error');
    }
  }
}

@riverpod
PushService pushService(Ref ref) => PushService(ref.watch(apiClientProvider));

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_store.g.dart';

/// Holds the Sanctum bearer token. Secure storage on Android and iOS;
/// on web this falls back to a less secure browser store, so the web
/// token is treated as lower-trust and lifetimes are kept short.
class TokenStore {
  TokenStore(this._storage);

  static const _tokenKey = 'sanctum_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}

@riverpod
TokenStore tokenStore(Ref ref) => TokenStore(const FlutterSecureStorage());

part of 'utils.dart';

enum SignerType { eoaWallet, privateKey, passkey, hardware }

class BiometricMiddlewareError extends Error {
  final String message =
      "requires auth, but Authentication middleware is not set";

  BiometricMiddlewareError();

  @override
  String toString() {
    return 'SecureStorageAuthMiddlewareError: $message';
  }
}

class SecureStorageMiddleware implements SecureStorageRepository {
  final AndroidOptions androidOptions;
  final IOSOptions iosOptions;

  final FlutterSecureStorage secureStorage;
  final Authentication? authMiddleware;

  final String? _credential;

  SecureStorageMiddleware(
      {required this.secureStorage, this.authMiddleware, String? credential})
      : androidOptions = AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iosOptions = const IOSOptions(
          accessibility: KeychainAccessibility.unlocked,
        ),
        _credential = credential;

  @override
  Future<void> delete(String key,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }
    await secureStorage.delete(key: "${options.namespace ?? "vaariance"}_$key");
  }

  @override
  Future<String?> read(String key,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }
    return await secureStorage.read(
        key: "${options.namespace ?? "vaariance"}_$key");
  }

  @override
  Future<String?> readCredential(SignerType type,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }
    return await secureStorage.read(
        key: "${options.namespace ?? "vaariance"}_${type.name}");
  }

  @override
  Future<void> save(String key, String value,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }

    await secureStorage.write(
        key: "${options.namespace ?? "vaariance"}_$key", value: value);
  }

  @override
  Future<void> saveCredential(SignerType type,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }
    await secureStorage.write(
        key: "${options.namespace ?? "vaariance"}_${type.name}",
        value: _credential);
  }

  @override
  Future<void> update(String key, String value,
      {StorageOptions? options = const StorageOptions()}) async {
    if (options!.requiresAuth) {
      if (authMiddleware == null) {
        throw BiometricMiddlewareError();
      }
      await authMiddleware?.authenticate(localizedReason: options.authReason);
    }

    await secureStorage.write(
        key: "${options.namespace ?? "vaariance"}_$key", value: value);
  }
}

class StorageOptions {
  final bool requiresAuth;
  final String authReason;
  // Namespace for uniquely addressing the secure storage keys.
  // if provided the secure storage keys will be prefixed with this value, defaults to "vaariance"
  // namespace ?? "vaariance" + "_" + identifier
  final String? namespace;

  const StorageOptions({bool? requiresAuth, String? authReason, this.namespace})
      : authReason = authReason ?? "unlock to access secure storage",
        requiresAuth = requiresAuth ?? false;
}

import 'package:pigeon/pigeon.dart';

enum DarwinAccessible {
  /// can only be accessed while the device is unlocked.
  whenUnlocked,

  /// can only be accessed once the device has been unlocked after a restart.
  afterFirstUnlock,

  /// can only be accessed while the device is unlocked on this device.
  whenUnlockedThisDeviceOnly,

  /// can only be accessed after the first unlock on this device.
  whenPasscodeSetThisDeviceOnly,

  /// can only be accessed after the first unlock on this device.
  afterFirstUnlockThisDeviceOnly,
}

final class DarwinOptions {
  final bool useSecureEnclave;
  final String? accessGroup;

  final bool requireUserAuthentication;
  final bool invalidateOnBiometricChange;
  final bool allowFallbackAuthentication;

  final bool isPermanent;

  final DarwinAccessible accessible;

  const DarwinOptions({
    required this.useSecureEnclave,
    this.accessGroup,
    required this.invalidateOnBiometricChange,
    required this.requireUserAuthentication,
    required this.allowFallbackAuthentication,
    required this.isPermanent,
    required this.accessible,
  });
}

@HostApi()
abstract class PlatformAuthenticator {
  /// Generates a new key pair in the secure element/keystore.
  /// Returns the public key as a 65-byte uncompressed byte array (0x04 || X || Y).
  /// Throws if generation fails.
  @async
  Uint8List createKey(String keyTag, DarwinOptions options);

  /// Deletes the key associated with the given tag.
  @async
  void deleteKey(String keyTag);

  /// Signs the data using the key associated with the given tag.
  /// Returns the signature (R || S) bytes.
  @async
  Uint8List sign(String keyTag, Uint8List data);

  /// Retrieves the public key for the given tag.
  /// Returns 65-byte uncompressed public key.
  @async
  Uint8List? getPublicKey(String keyTag);
}

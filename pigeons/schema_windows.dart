import 'package:pigeon/pigeon.dart';

final class WindowsOptions {
  final bool useTpm;

  final bool requireUserAuthentication;
  final bool invalidateOnBiometricChange;
  final bool allowFallbackAuthentication;

  final String uiPolicyFriendlyName;
  final String uiPolicyDescription;
  
  final Uint8List? attestationChallenge;

  const WindowsOptions({
    required this.useTpm,
    this.attestationChallenge,
    required this.uiPolicyFriendlyName,
    required this.uiPolicyDescription,
    required this.invalidateOnBiometricChange,
    required this.requireUserAuthentication,
    required this.allowFallbackAuthentication,
  });
}

@HostApi()
abstract class PlatformAuthenticator {
  /// Generates a new key pair in the secure element/keystore.
  /// Returns the public key as a 65-byte uncompressed byte array (0x04 || X || Y).
  /// Throws if generation fails.
  @async
  Uint8List createKey(String keyTag, WindowsOptions options);

  /// Deletes the key associated with the given tag.
  @async
  void deleteKey(String keyTag);

  /// Signs the data using the key associated with the given tag.
  /// Returns the signature (R || S) bytes.
  @async
  Uint8List sign(String keyTag, Uint8List data, WindowsOptions options);

  /// Retrieves the public key for the given tag.
  /// Returns 65-byte uncompressed public key.
  @async
  Uint8List? getPublicKey(String keyTag);
}

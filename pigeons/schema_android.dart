import 'package:pigeon/pigeon.dart';

final class AndroidOptions {
  final bool useStrongBoxKeyMint;
  final int authTimeoutSeconds;

  final bool requireUserAuthentication;
  final bool invalidateOnBiometricChange;
  final bool allowFallbackAuthentication;
  final bool userConfirmationRequired;

  final Uint8List? attestationChallenge;

  final String biometricPromptTitle;
  final String biometricPromptSubtitle;
  final String biometricPromptDescription;
  final String biometricPromptNegativeButtonText;

  const AndroidOptions({
    required this.useStrongBoxKeyMint,
    required this.authTimeoutSeconds,
    this.attestationChallenge,
    required this.invalidateOnBiometricChange,
    required this.requireUserAuthentication,
    required this.allowFallbackAuthentication,
    required this.userConfirmationRequired,
    required this.biometricPromptTitle,
    required this.biometricPromptSubtitle,
    required this.biometricPromptDescription,
    required this.biometricPromptNegativeButtonText,
  });
}

@HostApi()
abstract class PlatformAuthenticator {
  /// Generates a new key pair in the secure element/keystore.
  /// Returns the public key as a 65-byte uncompressed byte array (0x04 || X || Y).
  /// Throws if generation fails.
  @async
  Uint8List createKey(String keyTag, AndroidOptions options);

  /// Deletes the key associated with the given tag.
  @async
  void deleteKey(String keyTag);

  /// Signs the data using the key associated with the given tag.
  /// Returns the signature (R || S) bytes.
  @async
  Uint8List sign(String keyTag, Uint8List data, AndroidOptions options);

  /// Retrieves the public key for the given tag.
  /// Returns 65-byte uncompressed public key.
  @async
  Uint8List? getPublicKey(String keyTag);
}

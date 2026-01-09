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
    this.useStrongBoxKeyMint = true,
    this.authTimeoutSeconds = 0,
    this.attestationChallenge,
    this.invalidateOnBiometricChange = true,
    this.requireUserAuthentication = true,
    this.allowFallbackAuthentication = false,
    this.userConfirmationRequired = false,
    this.biometricPromptTitle = "Authenticate",
    this.biometricPromptSubtitle = "Authenticate with Device",
    this.biometricPromptDescription =
        "Authenticate with your device to enable Secure Enclave crypto operation",
    this.biometricPromptNegativeButtonText = "Cancel",
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

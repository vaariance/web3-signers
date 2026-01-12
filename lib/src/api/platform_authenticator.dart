import "dart:io";

import "package:flutter/foundation.dart";
import "package:web3_signers/web3_signers.dart";

import "android_auth.g.dart" as android_auth;
import "darwin_auth.g.dart" as darwin_auth;
import "windows_auth.g.dart" as windows_auth;

export 'darwin_auth.g.dart' show DarwinAccessible;

/// Android-specific configuration options for platform authentication.
///
/// Wraps [android_auth.AndroidOptions] to provide easy access to Android-specific settings
/// such as attestation challenges, biometric prompts, and security levels.
class AndroidPlatformOptions extends android_auth.AndroidOptions {
  /// Creates a new instance of [AndroidPlatformOptions].
  ///
  /// - [attestationChallenge]: Random data used to verify the integrity of the key pair.
  /// - [useStrongBoxKeyMint]: Whether to prefer StrongBox KeyMint if available. Defaults to `true`.
  /// - [authTimeoutSeconds]: Duration in seconds for which authentication remains valid.
  /// - [requireUserAuthentication]: Whether user authentication is required to use the key. Defaults to `true`.
  /// - [invalidateOnBiometricChange]: Whether to invalidate the key if new biometrics are enrolled. Defaults to `true`.
  /// - [allowFallbackAuthentication]: Whether to allow fallback to device credentials (PIN/pattern/password).
  /// - [userConfirmationRequired]: Whether user confirmation is required (e.g. pressing a button).
  /// - [biometricPromptTitle]: Title for the biometric prompt dialog.
  /// - [biometricPromptSubtitle]: Subtitle for the biometric prompt dialog.
  /// - [biometricPromptDescription]: Description for the biometric prompt dialog.
  /// - [biometricPromptNegativeButtonText]: specific text for the negative button on the prompt.
  ///
  /// Example:
  /// ```dart
  /// final options = AndroidPlatformOptions(
  ///   useStrongBoxKeyMint: true,
  ///   requireUserAuthentication: true,
  ///   biometricPromptTitle: 'Authorize Transaction',
  /// );
  /// ```
  AndroidPlatformOptions({
    super.attestationChallenge,
    super.useStrongBoxKeyMint = true,
    super.authTimeoutSeconds = 0,
    super.requireUserAuthentication = true,
    super.invalidateOnBiometricChange = true,
    super.allowFallbackAuthentication = false,
    super.userConfirmationRequired = false,
    super.biometricPromptTitle = "Sign",
    super.biometricPromptSubtitle = "Sign Ethereum Data",
    super.biometricPromptDescription = "Authenticate to Sign Ethereum Data",
    super.biometricPromptNegativeButtonText = "Cancel",
  });
}

/// Darwin (iOS/macOS) specific configuration options for platform authentication.
///
/// Wraps [darwin_auth.DarwinOptions] to provide access settings like Secure Enclave usage,
/// authentication policies, and keychain access groups.
class DarwinPlatformOptions extends darwin_auth.DarwinOptions {
  /// Creates a new instance of [DarwinPlatformOptions].
  ///
  /// - [accessGroup]: The keychain access group to share items between apps.
  /// - [useSecureEnclave]: Whether to store the key in the Secure Enclave. Defaults to `true`.
  /// - [requireUserAuthentication]: Whether user authentication is required to access the key. Defaults to `true`.
  /// - [invalidateOnBiometricChange]: Whether adding a new biometric enrollment should invalidate the key. Defaults to `true`.
  /// - [allowFallbackAuthentication]: Whether to allow fallback to device passcode.
  /// - [isPermanent]: Whether the key should persist across app installs. Defaults to `true`.
  /// - [accessible]: When the key should be accessible (e.g., [DarwinAccessible.whenUnlocked]).
  ///
  /// Example:
  /// ```dart
  /// final options = DarwinPlatformOptions(
  ///   useSecureEnclave: true,
  ///   accessible: DarwinAccessible.whenUnlocked,
  /// );
  /// ```
  DarwinPlatformOptions({
    super.accessGroup,
    super.useSecureEnclave = true,
    super.requireUserAuthentication = true,
    super.invalidateOnBiometricChange = true,
    super.allowFallbackAuthentication = false,
    super.isPermanent = true,
    super.accessible = DarwinAccessible.whenUnlocked,
  });
}

/// Windows-specific configuration options for platform authentication.
///
/// Wraps [windows_auth.WindowsOptions] to provide settings for TPM usage and UI prompts.
class WindowsPlatformOptions extends windows_auth.WindowsOptions {
  /// Creates a new instance of [WindowsPlatformOptions].
  ///
  /// - [attestationChallenge]: Challenge data for key attestation.
  /// - [useTpm]: Whether to require TPM storage for the key. Defaults to `true`.
  /// - [requireUserAuthentication]: Whether user authentication (Hello) is required.
  /// - [uiPolicyFriendlyName]: Friendly name displayed in the Windows UI.
  /// - [uiPolicyDescription]: Description displayed in the Windows UI.
  ///
  /// Example:
  /// ```dart
  /// final options = WindowsPlatformOptions(
  ///   useTpm: true,
  ///   requireUserAuthentication: true,
  ///   uiPolicyFriendlyName: 'My App Key',
  /// );
  /// ```
  WindowsPlatformOptions({
    super.attestationChallenge,
    super.useTpm = true,
    super.requireUserAuthentication = true,
    super.uiPolicyFriendlyName = "Ethereum Signing Key",
    super.uiPolicyDescription = "Authorizes access to sign Ethereum data.",
  });
}

/// A record type encapsulating platform-specific options.
///
/// Use this to pass platform-specific configurations when performing operations
/// that might require them, such as creating keys or signing.
typedef PlatformOptions =
    ({
      AndroidPlatformOptions? android,
      DarwinPlatformOptions? darwin,
      WindowsPlatformOptions? windows,
    });

/// A cross-platform interface for hardware-backed authentication and signing.
///
/// This class provides a unified API to interact with platform-specific secure storage
/// and signing capabilities:
/// - **Android**: Uses Android Keystore System (and StrongBox if available).
/// - **iOS/macOS**: Uses Apple's Secure Enclave and Keychain Services.
/// - **Windows**: Uses Windows CNG (Cryptography Next Generation) and TPM.
class PlatformAuthenticator {
  @visibleForTesting
  late darwin_auth.PlatformAuthenticator darwinAuth =
      darwin_auth.PlatformAuthenticator();

  @visibleForTesting
  late android_auth.PlatformAuthenticator androidAuth =
      android_auth.PlatformAuthenticator();

  @visibleForTesting
  late windows_auth.PlatformAuthenticator windowsAuth =
      windows_auth.PlatformAuthenticator();

  PlatformAuthenticator();

  /// Creates a new hardware-backed key pair identified by [keyTag].
  ///
  /// Returns the public key as [Bytes].
  ///
  /// - [keyTag]: A unique identifier for the key.
  /// - [options]: Platform-specific options for key creation.
  ///
  /// Throws [UnsupportedError] if the current platform is not supported.
  /// Throws [ArgumentError] if required platform options are missing.
  ///
  /// Example:
  /// ```dart
  /// final authenticator = PlatformAuthenticator();
  /// final options = (
  ///   android: AndroidPlatformOptions(useStrongBoxKeyMint: true),
  ///   darwin: DarwinPlatformOptions(useSecureEnclave: true),
  ///   windows: WindowsPlatformOptions(useTpm: true),
  /// );
  /// final publicKey = await authenticator.createKey('my_secure_key', options);
  /// ```
  Future<Bytes> createKey(String keyTag, PlatformOptions options) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.createKey(
        keyTag,
        _require(options.windows, "windows"),
      ),
      "android" => androidAuth.createKey(
        keyTag,
        _require(options.android, "android"),
      ),
      "ios" || "macos" => darwinAuth.createKey(
        keyTag,
        _require(options.darwin, "darwin"),
      ),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

  /// Deletes the key pair identified by [keyTag].
  ///
  /// - [keyTag]: The unique identifier of the key to delete.
  ///
  /// Throws [UnsupportedError] if the current platform is not supported.
  ///
  /// Example:
  /// ```dart
  /// await authenticator.deleteKey('my_secure_key');
  /// ```
  Future<void> deleteKey(String keyTag) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.deleteKey(keyTag),
      "android" => androidAuth.deleteKey(keyTag),
      "ios" || "macos" => darwinAuth.deleteKey(keyTag),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

  /// Retrieves the public key associated with [keyTag].
  ///
  /// Returns `null` if no key is found for the given [keyTag].
  ///
  /// - [keyTag]: The unique identifier of the key to retrieve.
  ///
  /// Throws [UnsupportedError] if the current platform is not supported.
  ///
  /// Example:
  /// ```dart
  /// final publicKey = await authenticator.getPublicKey('my_secure_key');
  /// if (publicKey != null) {
  ///   print('Public Key found: $publicKey');
  /// }
  /// ```
  Future<Bytes?> getPublicKey(String keyTag) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.getPublicKey(keyTag),
      "android" => androidAuth.getPublicKey(keyTag),
      "ios" || "macos" => darwinAuth.getPublicKey(keyTag),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

  /// Signs [data] using the private key identified by [keyTag].
  ///
  /// Returns the signature as [Bytes].
  ///
  /// - [keyTag]: The unique identifier of the key to use for signing.
  /// - [data]: The data to sign.
  /// - [options]: Platform-specific options (e.g. authentication prompts).
  ///
  /// Throws [UnsupportedError] if the current platform is not supported.
  /// Throws [ArgumentError] if required platform options are missing.
  ///
  /// Example:
  /// ```dart
  /// final dataToSign = Bytes.fromList([1, 2, 3, 4]);
  /// final signature = await authenticator.sign(
  ///   'my_secure_key',
  ///   dataToSign,
  ///   options, // Re-use options or create new ones
  /// );
  /// ```
  Future<Bytes> sign(String keyTag, Bytes data, PlatformOptions options) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.sign(
        keyTag,
        data,
        _require(options.windows, "windows"),
      ),
      "android" => androidAuth.sign(
        keyTag,
        data,
        _require(options.android, "android"),
      ),
      "ios" || "macos" => darwinAuth.sign(keyTag, data),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

  T _require<T>(T? option, String platform) {
    if (option == null) {
      throw ArgumentError(
        "Platform Authenticator: No options provided for $platform",
      );
    }
    return option;
  }
}

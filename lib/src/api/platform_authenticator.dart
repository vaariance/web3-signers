import "dart:io";

import "package:flutter/foundation.dart";
import "package:web3_signers/web3_signers.dart";

import "android_auth.g.dart" as android_auth;
import "darwin_auth.g.dart" as darwin_auth;
import "windows_auth.g.dart" as windows_auth;

export 'darwin_auth.g.dart' show DarwinAccessible;

class AndroidPlatformOptions extends android_auth.AndroidOptions {
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

class DarwinPlatformOptions extends darwin_auth.DarwinOptions {
  DarwinPlatformOptions({
    super.accessGroup,
    super.useSecureEnclave = true,
    super.requireUserAuthentication = true,
    super.invalidateOnBiometricChange = true,
    super.allowFallbackAuthentication = false,
    super.isParmanent = true,
    super.accessible = DarwinAccessible.whenUnlocked,
  });
}

class WindowsPlatformOptions extends windows_auth.WindowsOptions {
  WindowsPlatformOptions({
    super.attestationChallenge,
    super.useTpm = true,
    super.requireUserAuthentication = true,
    super.uiPolicyFriendlyName = "Ethereum Signing Key",
    super.uiPolicyDescription = "Authorizes access to sign Ethereum data.",
  });
}

typedef PlatformOptions =
    ({
      AndroidPlatformOptions? android,
      DarwinPlatformOptions? darwin,
      WindowsPlatformOptions? windows,
    });

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

  Future<void> deleteKey(String keyTag) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.deleteKey(keyTag),
      "android" => androidAuth.deleteKey(keyTag),
      "ios" || "macos" => darwinAuth.deleteKey(keyTag),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

  Future<Bytes?> getPublicKey(String keyTag) async {
    return switch (Platform.operatingSystem) {
      "windows" => windowsAuth.getPublicKey(keyTag),
      "android" => androidAuth.getPublicKey(keyTag),
      "ios" || "macos" => darwinAuth.getPublicKey(keyTag),
      _ => throw UnsupportedError("Unsupported platform"),
    };
  }

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

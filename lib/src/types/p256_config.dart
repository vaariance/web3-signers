part of '../../web3_signers.dart';

@Deprecated("use PassKeyConfig")
typedef PassKeysOptions = PassKeyConfig;

sealed class P256Config {}

/// Represents platform-specific configuration for P256 keys.
///
/// This configuration is typically used for hardware-backed keys stored
/// in the device's secure enclave or keystore.
interface class PlatformConfig implements P256Config {
  /// The unique identifier used to store and retrieve the key from the platform storage.
  final String keyTag;

  /// Creates a new instance of [PlatformConfig].
  ///
  /// Parameters:
  /// - [keyTag]: The unique identifier for the key.
  const PlatformConfig({required this.keyTag});
}

/// Represents options for PassKeys operations, extending SignatureOptions.
///
/// This class encapsulates various parameters required for PassKeys authentication
/// and signature processes.
interface class PassKeyConfig implements P256Config {
  @Deprecated("use rpId")
  final String namespace;

  @Deprecated("use rpName")
  final String name;

  /// The relying party id or domain name.
  /// e.g variance.space
  final String rpId;

  /// The name of the relying party.
  /// e.g variance
  final String rpName;

  /// The level of user verification required.
  ///
  /// Defaults to "required".
  final String userVerification;

  /// Indicates whether a resident key is required.
  ///
  /// Defaults to true.
  final bool requireResidentKey;

  /// The type of resident key requirement.
  /// ["required"] or ["preferred"] or ["discouraged"].
  ///
  /// Defaults to "preferred".
  final String residentKey;

  /// The authenticator attachment to use
  /// ["cross-platform"] or ["platform"]
  ///
  /// Defaults to "cross-platform"
  final String authenticatorAttachment;

  /// The mediation type for the PassKeys operation.
  ///
  /// ["conditional"] or ["optional"] or ["silent"] or ["required"].
  ///
  /// Defaults to "optional".
  final String mediation;

  final int timeout;

  final List<PassKeyTransports> transports;

  /// Creates a new instance of PassKeysOptions.
  ///
  /// Parameters:
  /// - [rpId]: The namespace for the PassKeys operation.
  /// - [rpName]: The name associated with the PassKeys operation.
  /// - [userVerification]: The level of user verification required. Defaults to "required".
  /// - [requireResidentKey]: Indicates whether a resident key is required. Defaults to true.
  /// - [residentKey]: The type of resident key. Defaults to "preferred".
  /// - [authenticatorAttachment]: The cross-platform or platform.
  /// - [mediation]: The mediation type for the PassKeys operation. Defaults to "conditional".
  ///
  /// Example:
  /// ```dart
  /// final options = WebAuthnConfig(
  ///   rpId: 'com.example',
  ///   rpName: 'ExampleApp',
  ///   origin: 'https://example.com',
  ///   sharedWebauthnSigner: EthereumAddress.fromHex('0x1234...'),
  ///   challenge: 'randomChallenge123',
  ///   type: 'webauthn'
  /// );
  /// ```
  const PassKeyConfig({
    required this.rpId,
    required this.rpName,
    @Deprecated("use rpId") this.namespace = "",
    @Deprecated("use rpName") this.name = "",
    this.userVerification = "required",
    this.requireResidentKey = true,
    this.residentKey = "preferred",
    this.authenticatorAttachment = "cross-platform",
    this.mediation = "optional",
    this.timeout = 60000,
    this.transports = const [
      PassKeyTransports.bluetooth,
      PassKeyTransports.device,
      PassKeyTransports.nfc,
      PassKeyTransports.usb,
    ],
  });
}

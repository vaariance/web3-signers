part of '../../web3_signers.dart';

/// A sealed base class representing an Elliptic Curve public key.
///
/// Contains the raw [x] and [y] coordinates as [Uint256].
sealed class PublicKey {
  /// The X coordinate of the public key.
  final Uint256 x;

  /// The Y coordinate of the public key.
  final Uint256 y;

  const PublicKey({required this.x, required this.y});
}

/// A public key generated from a purely local private key.
///
/// Use this for ephemeral keys or keys managed entirely within the application.
final class LocalPublicKey extends PublicKey {
  const LocalPublicKey({required super.x, required super.y});
}

/// A public key associated with a WebAuthn/Passkey credential.
///
/// Includes additional metadata required for passkey authentication:
/// - [credentialId]: The unique identifier for the credential.
/// - [userName]: The username associated with the key.
/// - [aaGuid]: The Authenticator Attestation GUID.
final class PassKeyPublicKey extends PublicKey {
  /// The raw credential ID bytes.
  final Bytes credentialId;

  /// The associated username.
  final String userName;

  /// The authenticator attestation GUID.
  final String aaGuid;

  const PassKeyPublicKey({
    required super.x,
    required super.y,
    required this.credentialId,
    required this.userName,
    required this.aaGuid,
  });
}

/// A public key backed by a platform-specific secure hardware element.
///
/// This key is associated with a key pair stored in:
/// - Android Keystore (StrongBox)
/// - iOS Secure Enclave
/// - Windows TPM/CNG
final class PlatformPublicKey extends PublicKey {
  PlatformPublicKey({required super.x, required super.y});
}

/// Represents an Elliptic Curve Digital Signature Algorithm (ECDSA) signature.
///
/// Extends [ECSignature] to support standard Ethereum signing as well as
/// passkey-specific signature data.
///
/// - `v`: v is intrinsically normalized to 27 or 28. regardless of EIP-1559.
///   This encourages the use of `yParity` over `v` unless needed.
///
/// Includes fields for Passkey (WebAuthn) validation:
/// - [authData]: Authenticator data from the WebAuthn response.
/// - [clientDataJson]: The JSON client data collected during the signature operation.
final class Signature extends ECSignature implements MsgSignature {
  final int yParity;

  @override
  final int v;

  /// Authenticator data for passkey signatures.
  final Bytes? authData;

  /// Client data JSON for passkey signatures.
  final String? clientDataJson;

  /// The curve used for signing.
  final SigningCurve? curve;

  Signature(
    super.r,
    super.s, {
    this.yParity = 0,
    this.authData,
    this.clientDataJson,
    this.curve,
  }) : v = 27 + yParity;

  /// Finds the index of the [payload] within the [clientDataJson].
  ///
  /// Used for proving that the signed challenge matches the signed data.
  int? getChallengeLocation(Bytes payload) {
    return clientDataJson?.indexOf(b64e(payload));
  }

  /// Finds the index of the `"type"` field in [clientDataJson].
  ///
  /// Important for certain on-chain validators (e.g., Kernel) that require precise
  /// offsets for parsing the client data.
  int? getTypeLocation() {
    // Return position of '"type"' key, not 'webauthn.get' value.
    // The Kernel WebAuthn validator expects the index of the type field.
    return clientDataJson?.indexOf('"type"');
  }

  @override
  Signature normalize(ECDomainParameters curveParams) {
    if (isNormalized(curveParams)) {
      return this;
    }
    final parity = yParity ^ 1;
    return Signature(
      r,
      curveParams.n - s,
      yParity: parity,
      authData: authData,
      clientDataJson: clientDataJson,
      curve: curve,
    );
  }

  /// Creates a [Signature] from a 64 or 65 byte list.
  ///
  /// Expects `[R (32 bytes) || S (32 bytes) || V (optional 1 byte)]`.
  factory Signature.fromBytes(Bytes bytes, SigningCurve curve) {
    final v = bytes[64];
    final yParity = (v == 27 || v == 28) ? v - 27 : 0;
    return Signature(
      bytesToUnsignedInt(bytes.sublist(0, 32)),
      bytesToUnsignedInt(bytes.sublist(32, 64)),
      yParity: yParity,
      curve: curve,
    );
  }
}

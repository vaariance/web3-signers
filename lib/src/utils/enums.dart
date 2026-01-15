import 'package:pointycastle/export.dart';
import 'package:web3_signers/web3_signers.dart' show Uint32;

/// The type of signer used to sign transactions.
enum SignerType { localKey, platformKey, passKey }

/// The response code returned by a smart contract when verifying a signature via EIP-1271.
enum IsValidSignatureResponse {
  /// The magic value returning success (0x1626ba7e).
  success("0x1626ba7e"),

  /// The value indicating failure (0xffffffff).
  failure("0xffffffff");

  final String value;

  const IsValidSignatureResponse(this.value);

  factory IsValidSignatureResponse.isValid(bool value) {
    return value ? success : failure;
  }

  factory IsValidSignatureResponse.isValidResult(Uint32 result) {
    return result.toHex().toLowerCase() == "0x1626ba7e" ? success : failure;
  }
}

/// The strength of the mnemonic phrase in bits.
enum WordLength {
  /// 12 words (128 bits of entropy).
  word_12(128),

  /// 24 words (256 bits of entropy).
  word_24(256);

  final int wordsStrength;

  const WordLength(this.wordsStrength);
}

/// The transport mechanisms available for Passkey authentication.
enum PassKeyTransports {
  /// Bluetooth Low Energy.
  bluetooth("ble"),

  /// USB.
  usb("usb"),

  /// Near Field Communication.
  nfc("nfc"),

  /// Internal transport (e.g., Touch ID, Face ID).
  device("internal");

  final String transport;

  const PassKeyTransports(this.transport);
}

/// The level of attestation provided by the authenticator during registration.
enum PasskeyAttestationLevel { none, indirect, direct, enterprise }

/// The elliptic curve used for signing.
enum SigningCurve {
  /// secp256r1 (NIST P-256).
  r1,

  /// secp256k1 (Bitcoin/Ethereum).
  k1,
}

/// Extensions on [SigningCurve] to retrieve curve parameters and digest algorithms.
extension SigningCurveX on SigningCurve {
  /// Returns the domain parameters for this curve.
  ECDomainParameters get curveParams {
    switch (this) {
      case SigningCurve.r1:
        return ECCurve_secp256r1();
      case SigningCurve.k1:
        return ECCurve_secp256k1();
    }
  }

  /// Returns the message digest algorithm for this curve.
  Digest get digest {
    switch (this) {
      case SigningCurve.r1:
        return SHA256Digest();
      case SigningCurve.k1:
        return KeccakDigest(256);
    }
  }
}

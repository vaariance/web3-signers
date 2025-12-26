import 'package:pointycastle/export.dart';
import 'package:web3_signers/web3_signers.dart' show Uint32;

enum SignerType { localKey, platformKey, passKey }

enum ERC1271IsValidSignatureResponse {
  success("0x1626ba7e"),
  failure("0xffffffff");

  final String value;

  const ERC1271IsValidSignatureResponse(this.value);

  factory ERC1271IsValidSignatureResponse.isValid(bool value) {
    return value ? success : failure;
  }

  factory ERC1271IsValidSignatureResponse.isValidResult(Uint32 result) {
    return result.toHex().toLowerCase() == "0x1626ba7e" ? success : failure;
  }
}

enum WordLength {
  word_12(128),
  word_24(256);

  final int wordsStrength;

  const WordLength(this.wordsStrength);
}

enum PassKeyTransports {
  bluetooth("ble"),
  usb("usb"),
  nfc("nfc"),
  device("internal");

  final String transport;

  const PassKeyTransports(this.transport);
}

enum PasskeyAttestationLevel { none, indirect, direct, enterprise }

/// Categorizes all non standard key type
/// - webauthn - for passkeys
/// - secureElement - for platform keys like (keystore,TPM,secure enclave)
/// - physical - for hardware keys like (ledger, trezor, etc)
/// - server - for server side keys like (server wallets, mpcs, TEE keys, etc)
enum GenericKeyType { webauthn, secureElement, physical, server }

enum SigningCurve { r1, k1 }

extension SigningCurveX on SigningCurve {
  ECDomainParameters get curveParams {
    switch (this) {
      case SigningCurve.r1:
        return ECCurve_secp256r1();
      case SigningCurve.k1:
        return ECCurve_secp256k1();
    }
  }

  Digest get digest {
    switch (this) {
      case SigningCurve.r1:
        return SHA256Digest();
      case SigningCurve.k1:
        return KeccakDigest(256);
    }
  }
}

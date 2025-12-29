part of '../../web3_signers.dart';

@Deprecated("use PassKeyPublicKey")
typedef PassKeyPair = PassKeyPublicKey;

@Deprecated("use Signature")
typedef PassKeySignature = Signature;

sealed class PublicKey {
  final Uint256 x;
  final Uint256 y;

  const PublicKey({required this.x, required this.y});
}

final class LocalPublicKey extends PublicKey {
  const LocalPublicKey({required super.x, required super.y});
}

final class PassKeyPublicKey extends PublicKey {
  final Bytes credentialId;
  final String userName;
  final String aaGuid;

  const PassKeyPublicKey({
    required super.x,
    required super.y,
    required this.credentialId,
    required this.userName,
    required this.aaGuid,
  });
}

final class PlatformPublicKey extends PublicKey {
  PlatformPublicKey({required super.x, required super.y});
}

final class Signature extends EIP7702MsgSignature implements ECSignature {
  final Bytes? authData;
  final String? clientDataJson;

  final SigningCurve? curve;

  Signature(
    BigInt r,
    BigInt s, {
    int yParity = 0,
    this.authData,
    this.clientDataJson,
    this.curve,
  }) : super(r, s, 27 + yParity, yParity);

  int? getChallengeLocation(Bytes digest) {
    return clientDataJson?.indexOf(b64e(digest));
  }

  int? getTypeLocation() {
    // Return position of '"type"' key, not 'webauthn.get' value.
    // The Kernel WebAuthn validator expects the index of the type field.
    return clientDataJson?.indexOf('"type"');
  }

  @override
  bool isNormalized(ECDomainParameters curveParams) {
    return !(s.compareTo(curveParams.n >> 1) > 0);
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

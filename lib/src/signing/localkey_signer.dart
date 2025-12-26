part of '../../web3_signers.dart';

@Deprecated("use LocalKeySigner")
typedef EOAWallet = LocalKeySigner;

@Deprecated("use LocalKeySigner")
typedef PrivateKeySigner = LocalKeySigner;

final class LocalKeySigner implements Eip1271Signer {
  final EthPrivateKey _ethPrivateKey;

  factory LocalKeySigner.fromMnemonic(String mnemonic) {
    final privateKey = mnemonicToPrivateKey(mnemonic);
    return LocalKeySigner._(EthPrivateKey(privateKey));
  }

  factory LocalKeySigner.fromRawPrivateKey(Bytes privateKey) {
    return LocalKeySigner._(EthPrivateKey(privateKey));
  }

  const LocalKeySigner._(this._ethPrivateKey);

  EthPrivateKey get ethPrivateKey => _ethPrivateKey;

  LocalPublicKey get publicKey {
    final publicKey = _ethPrivateKey.encodedPublicKey;

    return LocalPublicKey(
      x: publicKey.sublist(0, 32).let(Uint256.fromBytes)!,
      y: publicKey.sublist(32, 64).let(Uint256.fromBytes)!,
    );
  }

  @override
  SignerType get kind => SignerType.localKey;

  @override
  bool get isRecoverable => true;

  @override
  bool get supportsUserPresence => false;

  @override
  bool get supportsUserVerification => false;

  @override
  bool get supportsSyncSigning => true;

  @override
  HexString getAddress() {
    return _ethPrivateKey.address.eip55With0x;
  }

  @override
  Signature getDummySignature() {
    return Signature.fromBytes(
      hexToBytes("0x${'ec' * 32}${'d5a' * 21}f1b"),
      SigningCurve.k1,
    );
  }

  @override
  Future<Signature> personalSign(Bytes message) {
    final signature = _ethPrivateKey.signPersonalMessageToUint8List(message);
    return Future.value(Signature.fromBytes(signature, SigningCurve.k1));
  }

  @override
  Signature sign(Bytes preImage) {
    final sig = _ethPrivateKey.signToEcSignature(preImage, isEIP1559: true);
    return Signature(sig.r, sig.s, yParity: sig.v, curve: SigningCurve.k1);
  }

  @override
  Future<Signature> signAsync(Bytes preImage) {
    return Future.value(sign(preImage));
  }

  @override
  @Deprecated('Use sign and/or signAsync instead')
  Future<MsgSignature> signToEc(Bytes preImage) {
    return Future.value(sign(preImage));
  }

  @override
  Future<Signature> signTypedData(
    TypedMessage jsonData,
    TypedDataVersion version,
  ) {
    final hash = hashTypedData(typedData: jsonData, version: version);
    final signature = _ethPrivateKey.signToUint8List(hash);
    return Future.value(Signature.fromBytes(signature, SigningCurve.k1));
  }
}

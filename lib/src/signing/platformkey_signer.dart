part of '../../web3_signers.dart';

/// A signer that uses a platform-specific key (KeyStore/Keychain) for signing.
///
/// This signer interacts with a [PlatformAuthenticator] to perform secure signing operations
/// backed by hardware security modules (HSM) or TEE where available.
final class PlatformKeySigner implements Signer {
  final PlatformAuthenticator _authenticator;
  final PlatformConfig _config;

  final PlatformPublicKey _key;

  /// Creates a [PlatformKeySigner] with a specific configuration and public key.
  ///
  /// Uses the default [PlatformAuthenticator].
  factory PlatformKeySigner.withConfig(
    PlatformConfig config,
    PlatformPublicKey key,
  ) {
    return PlatformKeySigner._(PlatformAuthenticator(), config, key);
  }

  /// Creates a [PlatformKeySigner] with a custom authenticator.
  ///
  /// This factory prevents the default [PlatformAuthenticator] from being used,
  /// allowing for dependency injection or custom implementations.
  factory PlatformKeySigner.withAuthenticator(
    PlatformAuthenticator authenticator,
    PlatformConfig config,
    PlatformPublicKey key,
  ) {
    return PlatformKeySigner._(authenticator, config, key);
  }

  PlatformKeySigner._(this._authenticator, this._config, this._key);

  @override
  PlatformPublicKey get publicKey => _key;

  @override
  SignerType get kind => SignerType.platformKey;

  @override
  bool get isRecoverable => false;

  @override
  bool get supportsUserPresence => true;

  @override
  bool get supportsUserVerification => true;

  @override
  bool get supportsSyncSigning => false;

  /// Deletes the signing key from the platform's secure storage.
  ///
  /// This operation is irreversible.
  Future<void> deleteSigningKey() async {
    await _authenticator.deleteKey(_config.keyTag);
  }

  @override
  HexString getAddress() {
    // Tempo Spec / P256 Address derivation: last 20 bytes of keccak256(X || Y)
    final publicKeyBytes = _key.x.toBytes().concat(_key.y.toBytes());
    final hash = keccak256(publicKeyBytes);
    final addressBytes = hash.sublist(12, 32);
    return addressBytes.toHex();
  }

  @override
  Signature getDummySignature() {
    return Signature(
      BigInt.parse('0x${'ec' * 32}'),
      BigInt.parse('0x${'d5a' * 21}f'),
    );
  }

  @override
  Future<Signature> personalSign(Bytes message) async {
    final prefix = '\u0019Ethereum Signed Message:\n${message.length}';
    final preImage = ascii.encode(prefix).concat(message);
    final signature = await signAsync(preImage);
    return signature;
  }

  @override
  Signature sign(Bytes preImage) {
    throw UnsupportedError("Sync signing not supported for PlatformKeySigner");
  }

  @override
  Future<Signature> signAsync(Bytes preImage) async {
    final sigBytes = await _authenticator.sign(_config.keyTag, preImage, (
      android: _config.androidOptions,
      darwin: _config.darwinOptions,
      windows: _config.windowsOptions,
    ));
    final sig = getMessagingSignature(Bytes.fromList(sigBytes));
    final curve = SigningCurve.r1;
    final ecSig = Signature(sig.r.value, sig.s.value, curve: curve);
    return ecSig.normalize(curve.curveParams);
  }

  @override
  Future<MsgSignature> signToEc(Bytes preImage) async {
    return signAsync(preImage);
  }

  @override
  Future<Signature> signTypedData(
    TypedMessage jsonData,
    TypedDataVersion version,
  ) async {
    final hash = hashTypedData(typedData: jsonData, version: version);
    final signature = await signAsync(hash);
    return signature;
  }
}

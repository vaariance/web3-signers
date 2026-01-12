part of '../../web3_signers.dart';

/// A signer that uses a Passkey (WebAuthn) for signing.
///
/// This signer interacts with a [PasskeyAuthenticator] to sign transactions and messages.
final class PassKeySigner implements Signer {
  final PasskeyAuthenticator _authenticator;
  final PassKeyConfig _config;

  final PassKeyPublicKey _key;

  /// Creates a [PassKeySigner] with a specific configuration and public key.
  ///
  /// Uses the default [PasskeyAuthenticator].
  factory PassKeySigner.withConfig(PassKeyConfig config, PassKeyPublicKey key) {
    return PassKeySigner._(PasskeyAuthenticator(), config, key);
  }

  /// Creates a [PassKeySigner] with a custom authenticator.
  ///
  /// This factory prevents the default [PasskeyAuthenticator] from being used,
  /// allowing for dependency injection or custom implementations.
  factory PassKeySigner.withAuthenticator(
    PasskeyAuthenticator authenticator,
    PassKeyConfig config,
    PassKeyPublicKey key,
  ) {
    return PassKeySigner._(authenticator, config, key);
  }

  const PassKeySigner._(this._authenticator, this._config, this._key);

  @override
  PassKeyPublicKey get publicKey => _key;

  @override
  SignerType get kind => SignerType.passKey;

  @override
  bool get isRecoverable => true;

  @override
  bool get supportsUserPresence => true;

  @override
  bool get supportsUserVerification => true;

  @override
  bool get supportsSyncSigning => false;

  // Tempo Spec: address(uint160(uint256(keccak256(abi.encodePacked(pubKeyX, pubKeyY)))))
  @override
  HexString getAddress() {
    final publicKeyBytes = _key.x.toBytes().concat(_key.y.toBytes());
    final hash = keccak256(publicKeyBytes);
    final addressBytes = hash.sublist(12, 32);
    return addressBytes.toHex();
  }

  @override
  Signature getDummySignature() {
    final uv = _config.userVerification == "required" ? 0x04 : 0x01;
    final dummyAdField = Uint8List(37);
    dummyAdField.fillRange(0, dummyAdField.length, 0xfe);
    dummyAdField[32] = uv;

    return Signature(
      BigInt.parse('0x${'ec' * 32}'),
      BigInt.parse('0x${'d5a' * 21}f'),
      curve: SigningCurve.r1,
      authData: dummyAdField,
      clientDataJson: dummyCdField,
    );
  }

  @override
  Future<Signature> personalSign(Bytes message) async {
    final prefix = eip191MessagePrefix + message.length.toString();
    final preImage = ascii.encode(prefix).concat(message);
    final signature = await signAsync(preImage);
    return signature;
  }

  @override
  Signature sign(Uint8List preImage) {
    throw UnsupportedError(
      'Passkey signing requires user interaction; use signAsync(preImage).',
    );
  }

  @override
  Future<Signature> signAsync(Uint8List preImage) async {
    final hashBase64 = b64e(preImage);

    final assertion = await _authenticate(hashBase64);
    final sig = getMessagingSignature(b64d(assertion.signature));

    final clientDataJSON = utf8.decode(b64d(assertion.clientDataJSON));
    final curve = SigningCurve.r1;

    final ecSig = Signature(
      sig.r.value,
      sig.s.value,
      authData: b64d(assertion.authenticatorData),
      clientDataJson: clientDataJSON,
      curve: curve,
    );

    // Normalize S to LOW-S form for on-chain verification (required by P256).
    return ecSig.normalize(curve.curveParams);
  }

  @Deprecated("use signAsync")
  @override
  Future<Signature> signToEc(Bytes preImage) {
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

  /// Signs a hash using the Passkey authenticator.
  ///
  /// This method is deprecated; use [signAsync] instead.
  @Deprecated("use SignAsync")
  Future<Signature> signToPasskeySignature(
    Uint8List hash, {
    List<CredentialType>? knownCredentials,
  }) {
    return signAsync(hash);
  }

  Future<AuthenticateResponseType> _authenticate(String challenge) async {
    final allowedCreds = [
      CredentialType(
        type: 'public-key',
        id: b64e(_key.credentialId),
        transports: _config.transports.map((t) => t.transport).toList(),
      ),
    ];
    final entity = AuthenticateRequestType(
      preferImmediatelyAvailableCredentials: false,
      relyingPartyId: _config.rpId,
      challenge: challenge,
      timeout: _config.timeout,
      userVerification: _config.userVerification,
      allowCredentials: allowedCreds.isEmpty ? null : allowedCreds,
      mediation: MediationType.values.firstWhere(
        (m) => m.name.toLowerCase() == _config.mediation.toLowerCase(),
      ),
    );
    return await _authenticator.authenticate(entity);
  }
}

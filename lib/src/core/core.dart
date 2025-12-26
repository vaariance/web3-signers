part of '../../web3_signers.dart';

/// Generates a new random secp256k1 private key.
///
/// - Uses `PointyCastle`’s `ECKeyGenerator` seeded with `SecureRandom()`.
/// - Returns a 32-byte private key.
Bytes generatePrivateKey() {
  final generator = ECKeyGenerator();
  generator.init(
    ParametersWithRandom(
      ECKeyGeneratorParameters(ECCurve_secp256k1()),
      SecureRandom(),
    ),
  );
  final keyPair = generator.generateKeyPair();
  return intToBytes(keyPair.privateKey.d!);
}

Future<PlatformPublicKey> generatePlatformKey({
  required PlatformConfig config,
  bool checkExisting = false,
}) async {
  final api = PlatformSignerApi();

  List<int>? pubKeyBytes;

  if (checkExisting) {
    pubKeyBytes = await api.getPublicKey(config.keyTag);
  }

  pubKeyBytes ??= await api.createKey(config.keyTag);

  if (pubKeyBytes.length != 65 || pubKeyBytes[0] != 0x04) {
    throw FormatException("Invalid public key format from platform");
  }
  final x = Uint256.fromBytes(Bytes.fromList(pubKeyBytes.sublist(1, 33)));
  final y = Uint256.fromBytes(Bytes.fromList(pubKeyBytes.sublist(33, 65)));

  return PlatformPublicKey(x: x, y: y);
}

Future<PassKeyPublicKey> generatePassKey({
  required PassKeyConfig config,
  required String username,
  required String displayname,
  String? userIdBase64,
  String? challenge,
  PasskeyAttestationLevel attestationLevel = PasskeyAttestationLevel.none,
  List<Bytes> excludedCredentials = const [],
}) async {
  final auth = PasskeyAuthenticator();

  excluded(List<Bytes> list) {
    return list
        .map(
          (e) => CredentialType(
            type: 'public-key',
            id: b64e(e),
            transports: config.transports.map((t) => t.transport).toList(),
          ),
        )
        .toList();
  }

  final entity = RegisterRequestType(
    challenge: challenge ?? b64e(getRandomValues()),
    relyingParty: RelyingPartyType(id: config.rpId, name: config.rpName),
    user: UserType(
      id: userIdBase64 ?? b64e(generateUuidV4()),
      displayName: displayname,
      name: username,
    ),
    authSelectionType: AuthenticatorSelectionType(
      requireResidentKey: config.requireResidentKey,
      residentKey: config.residentKey,
      authenticatorAttachment: config.authenticatorAttachment,
      userVerification: config.userVerification,
    ),
    pubKeyCredParams: [PubKeyCredParamType(type: 'public-key', alg: -7)],
    timeout: config.timeout,
    attestation: attestationLevel.name,
    excludeCredentials: excluded(excludedCredentials),
  );

  final attestation = await auth.register(entity);
  final (pubKey, credentialId, aaGuid) = _parsePassKeyResponse(attestation);

  return PassKeyPublicKey(
    x: pubKey!.$1,
    y: pubKey.$2,
    credentialId: credentialId,
    aaGuid: aaGuid,
    userName: username,
  );
}

((Uint256, Uint256)?, Bytes, String) _parsePassKeyResponse(
  RegisterResponseType attestation,
) {
  final attestationAsCbor = b64d(attestation.attestationObject);
  final authdata = extractCBORPattern(attestationAsCbor);
  // Extract the length of the public key from the authentication data.
  final l = (authdata![53] << 8) + authdata[54];
  // Calculate the offset for the start of the public key data.
  final publicKeyOffset = 55 + l;
  // Extract the public key data from the authentication data.
  final pKey = authdata.sublist(publicKeyOffset);
  // Extract the credential ID from the authentication data.
  final Bytes credentialId = authdata.sublist(55, publicKeyOffset);
  // Extract and encode the aaGUID from the authentication data.
  final aaGuid = base64Url.encode(authdata.sublist(37, 53));
  // Decode the CBOR-encoded public key and convert it to a map.
  final decodedPubKey = extractXYFromCoseKey(pKey);
  return (decodedPubKey, credentialId, aaGuid);
}

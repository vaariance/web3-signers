part of '../../web3_signers.dart';

/// Generates a new random secp256k1 private key.
///
/// Uses `PointyCastle`'s `ECKeyGenerator` seeded with a cryptographically secure
/// random number generator ([Random.secure]).
///
/// Returns a 32-byte [Bytes] list representing the private key.
Bytes generatePrivateKey() {
  final generator = ECKeyGenerator();
  generator.init(
    ParametersWithRandom(
      ECKeyGeneratorParameters(ECCurve_secp256k1()),
      RandomBridge(Random.secure()),
    ),
  );
  final keyPair = generator.generateKeyPair();
  return unsignedIntToBytes(keyPair.privateKey.d!);
}

/// Generates a new key pair using the platform's secure hardware authenticator.
///
/// This function coordinates with the [PlatformAuthenticator] to create a persistent
/// key pair identifying the user or device.
///
/// - [config]: Configuration parameters including the key tag and platform-specific options.
/// - [checkExisting]: If `true`, attempts to retrieve an existing public key for the tag before creating a new one. Defaults to `false`.
/// - [auth]: Optional instance of [PlatformAuthenticator]. Defaults to a new instance.
///
/// Returns a [PlatformPublicKey] containing the purely public components (X and Y coordinates).
///
/// Throws [FormatException] if the returned public key is invalid.
///
/// Example:
/// ```dart
/// final config = PlatformConfig(
///   keyTag: 'com.example.app.signing_key',
///   androidOptions: AndroidPlatformOptions(useStrongBoxKeyMint: true),
/// );
/// final publicKey = await generatePlatformKey(config: config);
/// ```
Future<PlatformPublicKey> generatePlatformKey({
  required PlatformConfig config,
  bool checkExisting = false,
  PlatformAuthenticator? auth,
}) async {
  auth ??= PlatformAuthenticator();

  Bytes? pubKeyBytes;

  if (checkExisting) {
    pubKeyBytes = await auth.getPublicKey(config.keyTag);
  }

  pubKeyBytes ??= await auth.createKey(config.keyTag, (
    android: config.androidOptions ?? AndroidPlatformOptions(),
    darwin: config.darwinOptions ?? DarwinPlatformOptions(),
    windows: config.windowsOptions ?? WindowsPlatformOptions(),
  ));
  if (pubKeyBytes.length != 65 || pubKeyBytes[0] != 0x04) {
    throw FormatException("Invalid public key format from platform");
  }
  final x = Uint256.fromBytes(pubKeyBytes.sublist(1, 33));
  final y = Uint256.fromBytes(pubKeyBytes.sublist(33, 65));

  return PlatformPublicKey(x: x, y: y);
}

/// Registers a new WebAuthn/Passkey credential with a relying party.
///
/// This function handles the creation of a new passkey credential, including
/// setting up the user entity, selection criteria, and parsing the attestation response.
///
/// - [config]: Configuration for the passkey registration (RP ID, timeout, etc.).
/// - [username]: The human-readable name of the user (e.g., email address).
/// - [displayname]: The display name of the user.
/// - [userIdBase64]: Optional Base64 encoded user ID. If null, a random UUIDv4 is generated.
/// - [challenge]: Optional Base64 encoded challenge. If null, a random challenge is generated.
/// - [attestationLevel]: The desired attestation level. Defaults to [PasskeyAttestationLevel.none].
/// - [excludedCredentials]: A list of credential IDs to exclude (to prevent re-registration).
/// - [auth]: Optional instance of [PasskeyAuthenticator]. Defaults to a new instance.
///
/// Returns a [PassKeyPublicKey] containing the public key coordinates and credential metadata.
///
/// Example:
/// ```dart
/// final config = PassKeyConfig(rpId: 'example.com', rpName: 'Example App');
/// final credential = await generatePassKey(
///   config: config,
///   username: 'user@example.com',
///   displayname: 'User Name',
/// );
/// ```
Future<PassKeyPublicKey> generatePassKey({
  required PassKeyConfig config,
  required String username,
  required String displayname,
  String? userIdBase64,
  String? challenge,
  PasskeyAttestationLevel attestationLevel = PasskeyAttestationLevel.none,
  List<Bytes> excludedCredentials = const [],
  PasskeyAuthenticator? auth,
}) async {
  auth ??= PasskeyAuthenticator();

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
    excludeCredentials: _parseExcludedCredentials(excludedCredentials, config),
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

List<CredentialType> _parseExcludedCredentials(
  List<Bytes> list,
  PassKeyConfig config,
) {
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

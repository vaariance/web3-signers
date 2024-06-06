part of '../web3_signers_base.dart';

typedef Hex = String;

class AuthData {
  final Hex credentialHex;

  /// x and y coordinates of the public key
  final Tuple<Uint256, Uint256> publicKey;
  final String aaGUID;
  AuthData(this.credentialHex, this.publicKey, this.aaGUID);
}

class PassKeyPair {
  final Hex credentialHex;

  /// x and y coordinates of the public key
  final Tuple<Uint256, Uint256> publicKey;
  final String name;
  final String aaGUID;
  final DateTime registrationTime;
  PassKeyPair(this.credentialHex, this.publicKey, this.name, this.aaGUID,
      this.registrationTime);

  factory PassKeyPair.fromJson(String source) =>
      PassKeyPair.fromMap(json.decode(source) as Map<String, dynamic>);

  factory PassKeyPair.fromMap(Map<String, dynamic> map) {
    final pKey = List<String>.from(map['publicKey'])
        .map((e) => Uint256.fromHex(e))
        .toList();
    return PassKeyPair(
      map['credentialHex'],
      Tuple(pKey[0], pKey[1]),
      map['name'],
      map['aaGUID'],
      DateTime.fromMillisecondsSinceEpoch(map['registrationTime']),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'credentialHex': credentialHex,
      'publicKey': publicKey.toList().map((e) => e.toString()).toList(),
      'name': name,
      'aaGUID': aaGUID,
      'registrationTime': registrationTime.millisecondsSinceEpoch,
    };
  }
}

class PassKeySignature {
  final Hex credentialHex;

  /// r and s values of the signature.
  final Tuple<Uint256, Uint256> signature;
  final Uint8List authData;
  final String clientDataPrefix;
  final String clientDataSuffix;

  /// not decodable.
  final String userId;

  PassKeySignature(this.credentialHex, this.signature, this.authData,
      this.clientDataPrefix, this.clientDataSuffix, this.userId);

  /// Converts the `PassKeySignature` to a `Uint8List` using the specified ABI encoding.
  ///
  /// Returns the encoded Uint8List.
  ///
  /// Example:
  /// ```dart
  /// final Uint8List encodedSig = pkpSig.toUint8List();
  /// ```
  Uint8List toUint8List() {
    return abi.encode([
      'uint256',
      'uint256',
      'bytes',
      'string',
      'string'
    ], [
      signature.item1.value,
      signature.item2.value,
      authData,
      clientDataPrefix,
      clientDataSuffix
    ]);
  }
}

class PassKeySigner implements PasskeySignerInterface {
  final PassKeysOptions _opts;

  final PasskeyAuthenticator _auth;

  final Set<Hex> _knownCredentials;

  @override
  String dummySignature =
      "0xe017c9b829f0d550c9a0f1d791d460485b774c5e157d2eaabdf690cba2a62726b3e3a3c5022dc5301d272a752c05053941b1ca608bf6bc8ec7c71dfe15d5305900000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000025205f5f63c4a6cebdc67844b75186367e6d2e4f19b976ab0affefb4e981c22435050000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000247b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a2200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d222c226f726967696e223a226170692e776562617574686e2e696f227d000000";

  /// - [namespace] : the relying party entity id e.g "variance.space"
  /// - [name] : the relying party entity name e.g "Variance"
  /// - [origin] : the relying party entity origin. e.g "https://variance.space"
  /// - [crossOrigin] : whether the relying party entity is cross-origin. Defaults to `false`.
  /// - [knownCredentials] : a set of known credentials. Defaults to an empty set.
  PassKeySigner(String namespace, String name, String origin,
      {bool? crossOrigin, Set<Hex> knownCredentials = const {}})
      : _opts = PassKeysOptions(
          namespace: namespace,
          name: name,
          origin: origin,
          crossOrigin: crossOrigin ?? false,
        ),
        _auth = PasskeyAuthenticator(),
        _knownCredentials = knownCredentials;

  @override
  Set<Hex> get credentialIds => _knownCredentials;

  @override
  PassKeysOptions get opts => _opts;

  @override
  Uint8List clientDataHash(PassKeysOptions options, {String? challenge, String? secondChallenge}) {
    options.challenge = challenge ?? _randomBase64String();
    final clientDataJson = jsonEncode({
      "type": options.type,
      "challenge": options.challenge,
      "origin": options.origin,
      "crossOrigin": options.crossOrigin
    });
    final dataBuffer = utf8.encode(clientDataJson);
    final hash = sha256Hash(dataBuffer);
    return Uint8List.fromList(hash);
  }

  @override
  String credentialIdToHex(List<int> credentialId) {
    require(credentialId.length <= 32, "exception: credentialId too long");
    while (credentialId.length < 32) {
      credentialId.insert(0, 0);
    }
    return hexlify(credentialId);
  }

  @override
  String getAddress({int? index}) {
    return base64Url
        .encode(hexToCredentialId(_knownCredentials.elementAt(index ?? 0)));
  }

  @override
  Uint8List hexToCredentialId(String credentialHex) {
    if (credentialHex.startsWith("0x")) {
      credentialHex = credentialHex.substring(2);
    }

    List<int> credentialId = hexToBytes(credentialHex).toList();

    while (credentialId.isNotEmpty && credentialId[0] == 0) {
      credentialId.removeAt(0);
    }
    return Uint8List.fromList(credentialId);
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final signature = await signToPasskeySignature(hash, index: index);
    return signature.toUint8List();
  }

  @override
  Future<PassKeyPair> register(String username,
      [String displayname = "", bool requiresUserVerification = true, String? challenge]) async {
    final attestation =
        await _register(username, displayname, requiresUserVerification,challenge);
    final authData = _decodeAttestation(attestation);

    return PassKeyPair(
      authData.credentialHex,
      authData.publicKey,
      "$username $displayname".trimRight(),
      authData.aaGUID,
      DateTime.now(),
    );
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final signature = await signToPasskeySignature(hash, index: index);
    return MsgSignature(
        signature.signature.item1.value, signature.signature.item2.value, 0);
  }

  @override
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash,
      {int? index}) async {
    // Prepare hash
    final hashBase64 = b64e(hash);

    // Retrive known credentials if any
    final List<Hex> credentialIds;
    if (index != null) {
      credentialIds = _knownCredentials.elementAtOrNull(index) != null
          ? [_knownCredentials.elementAt(index)]
          : _knownCredentials.toList();
    } else {
      credentialIds = _knownCredentials.toList();
    }

    // convert credentialIds to CredentialType
    final List<CredentialType> credentials = credentialIds
        .map((e) => CredentialType(
            type: "public-key", id: b64e(hexToCredentialId(e)), transports: []))
        .toList();

    // Authenticate with passkey
    final assertion = await _authenticate(hashBase64, credentials, true);

    // Extract signature from response
    final sig = getMessagingSignature(b64d(assertion.signature));

    // Prepare challenge for response
    final clientDataJSON = utf8.decode(b64d(assertion.clientDataJSON));
    int challengePos = clientDataJSON.indexOf(hashBase64);
    String challengePrefix = clientDataJSON.substring(0, challengePos);
    String challengeSuffix =
        clientDataJSON.substring(challengePos + hashBase64.length);

    return PassKeySignature(
        credentialIdToHex(b64d(assertion.id).toList()),
        sig,
        b64d(assertion.authenticatorData),
        challengePrefix,
        challengeSuffix,
        assertion.userHandle);
  }

  Future<AuthenticateResponseType> _authenticate(String challenge,
      [List<CredentialType>? allowedCredentials,
      bool requiresUserVerification = true]) async {
    final entity = AuthenticateRequestType(
        relyingPartyId: _opts.namespace,
        challenge: challenge,
        timeout: 180000,
        userVerification: requiresUserVerification ? 'required' : 'preferred',
        allowCredentials: allowedCredentials,
        mediation: MediationType.Conditional);
    return await _auth.authenticate(entity);
  }

  AuthData _decode(List<int> authData) {
    // Extract the length of the public key from the authentication data.
    final l = (authData[53] << 8) + authData[54];

    // Calculate the offset for the start of the public key data.
    final publicKeyOffset = 55 + l;

    // Extract the public key data from the authentication data.
    final pKey = authData.sublist(publicKeyOffset);

    // Extract the credential ID from the authentication data.
    final List<int> credentialId = authData.sublist(55, publicKeyOffset);

    // Extract and encode the aaGUID from the authentication data.
    final aaGUID = base64Url.encode(authData.sublist(37, 53));

    // Decode the CBOR-encoded public key and convert it to a map.
    final decodedPubKey = CborObject.fromCbor(pKey) as CborMapValue;

    final keyX = decodedPubKey.value.entries
        .firstWhere((element) => element.key.value == -2);

    final keyY = decodedPubKey.value.entries
        .firstWhere((element) => element.key.value == -3);

    // Calculate the hash of the credential ID.
    final credentialHex = credentialIdToHex(credentialId);

    // Extract x and y coordinates from the decoded public key.
    final x = Uint256.fromHex(hexlify(keyX.value.value));
    final y = Uint256.fromHex(hexlify(keyY.value.value));

    return AuthData(credentialHex, Tuple(x, y), aaGUID);
  }

  AuthData _decodeAttestation(RegisterResponseType attestation) {
    final attestationAsCbor = b64d(attestation.attestationObject);
    final decodedAttestationAsCbor =
        CborObject.fromCbor(attestationAsCbor) as CborMapValue;

    final key = decodedAttestationAsCbor.value.entries
        .firstWhere((element) => element.key.value == "authData");
    final value = key.value.value;

    final authData = List<int>.from(value);
    return _decode(authData);
  }

  String _randomBase64String() {
    final uuid = UUID.generateUUIDv4();
    return b64e(UUID.toBuffer(uuid));
  }

  Future<RegisterResponseType> _register(String username,
      [String? displayname, bool requiresUserVerification = true, String? challenge]) async {
    final options = _opts;
    options.type = "webauthn.create";
    final entity = RegisterRequestType(
      challenge: b64e(clientDataHash(options,challenge: challenge)),
      relyingParty: RelyingPartyType(
        id: options.namespace,
        name: options.name,
      ),
      user: UserType(
        id: _randomBase64String(),
        displayName: displayname ?? username,
        name: username,
      ),
      authSelectionType: AuthenticatorSelectionType(
        requireResidentKey: true,
        residentKey: 'required',
        authenticatorAttachment: 'platform',
        userVerification: requiresUserVerification ? 'required' : 'preferred',
      ),
      pubKeyCredParams: [
        PubKeyCredParamType(
          type: 'public-key',
          alg: -7,
        ),
      ],
      timeout: 180000,
      attestation: 'none',
      excludeCredentials: [],
    );
    return await _auth.register(entity);
  }
}

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  bool? crossOrigin;
  String? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.crossOrigin,
      this.challenge,
      this.type});
}

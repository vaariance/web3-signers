part of '../web3_signers_base.dart';

typedef Bytes = Uint8List;

class AuthData {
  final String b64Credential;
  final Bytes rawCredential;

  /// x and y coordinates of the public key
  final Tuple<Uint256, Uint256> publicKey;
  final String aaGUID;
  AuthData(this.b64Credential, this.rawCredential, this.publicKey, this.aaGUID);
}

class PassKeyPair {
  final AuthData authData;

  final String username;
  final String? displayname;
  final DateTime? registrationTime;
  PassKeyPair(
      this.authData, this.username, this.displayname, this.registrationTime);

  factory PassKeyPair.fromJson(String source) =>
      PassKeyPair.fromMap(json.decode(source) as Map<String, dynamic>);

  factory PassKeyPair.fromMap(Map<String, dynamic> map) {
    final pKey = List<String>.from(map['publicKey'])
        .map((e) => Uint256.fromHex(e))
        .toList();
    return PassKeyPair(
      AuthData(
        map['b64Credential'],
        b64d(map['rawCredential']),
        Tuple(pKey[0], pKey[1]),
        map['aaGUID'],
      ),
      map['username'],
      map['displayname'],
      map['registrationTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['registrationTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'b64Credential': authData.b64Credential,
      'rawCredential': b64e(authData.rawCredential),
      'publicKey':
          authData.publicKey.toList().map((e) => e.toString()).toList(),
      'username': username,
      'displayname': displayname,
      'aaGUID': authData.aaGUID,
      'registrationTime': registrationTime?.millisecondsSinceEpoch,
    };
  }
}

class PassKeySignature {
  final String b64Credential;
  final Bytes credentialId;

  /// r and s values of the signature.
  final Tuple<Uint256, Uint256> signature;
  final Uint8List authData;
  final String clientDataJSON;
  final int challengePos;

  /// not decodable.
  final String userId;

  PassKeySignature(this.b64Credential, this.credentialId, this.signature,
      this.authData, this.clientDataJSON, this.challengePos, this.userId);

  /// Converts the `PassKeySignature` to a FCL compatible `Uint8List` using the specified ABI encoding.
  ///
  /// Returns the encoded Uint8List.
  /// abi.encode(['bytes', 'bytes', 'uint256[2]'], [authData, clientDataJSON, [r, s]])
  ///
  ///
  /// Example:
  /// ```dart
  /// final Uint8List encodedSig = pkpSig.toUint8List();
  /// ```
  Uint8List toUint8List() {
    final cdjRgExp = RegExp(
        r'^\{"type":"webauthn.get","challenge":"[A-Za-z0-9\-_]{43}",(.*)\}$');
    final match = cdjRgExp.firstMatch(clientDataJSON)!;
    return abi.encode([
      'bytes',
      'bytes',
      'uint256[2]'
    ], [
      authData,
      utf8.encode(match[0]!),
      [
        signature.item1.value,
        signature.item2.value,
      ]
    ]);
  }
}

class PassKeySigner implements PasskeySignerInterface {
  final PassKeysOptions _opts;

  final PasskeyAuthenticator _auth;

  final Set<Bytes> _knownCredentials;

  /// - [namespace] : the relying party entity id e.g "variance.space"
  /// - [name] : the relying party entity name e.g "Variance"
  /// - [origin] : the relying party entity origin. e.g "https://variance.space"
  /// - [knownCredentials] : a set of known credentials. Defaults to an empty set.
  PassKeySigner(String namespace, String name, String origin,
      {Set<Bytes> knownCredentials = const {}})
      : _opts = PassKeysOptions(
          namespace: namespace,
          name: name,
          origin: origin,
        ),
        _auth = PasskeyAuthenticator(),
        _knownCredentials = knownCredentials;

  @override
  Set<Bytes> get credentialIds => _knownCredentials;

  @override
  PassKeysOptions get opts => _opts;

  @override
  Uint8List clientDataHash(PassKeysOptions options, [String? challenge]) {
    options.challenge = challenge ?? randomBase64String();
    final clientDataJson = jsonEncode({
      "type": options.type,
      "challenge": options.challenge,
      "origin": options.origin,
    });
    final dataBuffer = utf8.encode(clientDataJson);
    final hash = sha256Hash(dataBuffer);
    return Uint8List.fromList(hash);
  }

  @override
  String getAddress({int? index}) {
    return b64e(_knownCredentials.elementAt(index ?? 0));
  }

  @override
  String getDummySignature<T>({required String prefix, T? getOptions}) {
    getOptions as Map<String, dynamic>;
    final signer = getOptions["signer"];
    final uv = getOptions["userVerification"] == "required" ? 0x04 : 0x01;
    final dummyCdField = [
      '"origin":"http://safe.global"',
      '"padding":"This pads the clientDataJSON so that we can leave room for additional implementation specific fields for a more accurate \'preVerificationGas\' estimate."',
    ].join(",");
    final dummyAdField = Uint8List(37);
    dummyAdField.fillRange(0, dummyAdField.length, 0xfe);
    dummyAdField[32] = uv;

    return buildSafeSignatureBytes(
        signer,
        PassKeySignature(
            "",
            Uint8List(0),
            Tuple<Uint256, Uint256>(Uint256.fromHex("0x${'ec' * 32}"),
                Uint256.fromHex("0x${'d5a' * 21}f")),
            dummyAdField,
            dummyCdField,
            0,
            ""));
  }

  @override
  String randomBase64String() {
    final uuid = UUID.generateUUIDv4();
    return b64e(UUID.toBuffer(uuid));
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final knownCredentials = _getKnownCredentials(index);
    final signature =
        await signToPasskeySignature(hash, knownCredentials: knownCredentials);
    return signature.toUint8List();
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final knownCredentials = _getKnownCredentials(index);
    final signature =
        await signToPasskeySignature(hash, knownCredentials: knownCredentials);
    return MsgSignature(
        signature.signature.item1.value, signature.signature.item2.value, 0);
  }

  @override
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash,
      {List<CredentialType>? knownCredentials}) async {
    // Prepare hash
    final hashBase64 = b64e(hash);

    // Authenticate with passkey
    final assertion = await _authenticate(hashBase64, knownCredentials);

    // Extract signature from response
    final sig = getMessagingSignature(b64d(assertion.signature));

    // Prepare challenge for response
    final clientDataJSON = utf8.decode(b64d(assertion.clientDataJSON));
    int challengePos = clientDataJSON.indexOf(hashBase64);

    return PassKeySignature(
        assertion.id,
        b64d(assertion.rawId),
        sig,
        b64d(assertion.authenticatorData),
        clientDataJSON,
        challengePos,
        assertion.userHandle);
  }

  @override
  Future<PassKeyPair> register(String username, String displayname,
      {String? challenge,
      bool requiresResidentKey = true,
      bool requiresUserVerification = true}) async {
    final attestation = await _register(
      username,
      displayname,
      challenge,
      requiresResidentKey,
      requiresUserVerification,
    );
    final authData = _decodeAttestation(attestation);

    return PassKeyPair(
      authData,
      username,
      displayname,
      DateTime.now(),
    );
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

    // Extract x and y coordinates from the decoded public key.
    final x = Uint256.fromHex(hexlify(keyX.value.value));
    final y = Uint256.fromHex(hexlify(keyY.value.value));

    return AuthData(b64e(credentialId), Uint8List.fromList(credentialId),
        Tuple(x, y), aaGUID);
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

  static String _getSignatureBytes(PassKeySignature signature) {
    String encodeUint256(BigInt x) => x.toRadixString(16).padLeft(64, '0');
    int byteSize(Uint8List data) => 32 * (((data.length + 31) ~/ 32) + 1);
    String encodeBytes(Uint8List data) {
      String hexData = hexlify(data);
      String result = encodeUint256(BigInt.from(data.length)) + hexData;
      return result.padRight(byteSize(data) * 2, '0');
    }

    int adOffset = 32 * 4;
    int cdjOffset = adOffset + byteSize(signature.authData);

    return '${encodeUint256(BigInt.from(adOffset))}${encodeUint256(BigInt.from(cdjOffset))}${encodeUint256(signature.signature.item1.value)}${encodeUint256(signature.signature.item2.value)}${encodeBytes(signature.authData)}${encodeBytes(Uint8List.fromList(utf8.encode(signature.clientDataJSON)))}';
  }

  List<CredentialType> _getKnownCredentials([int? index]) {
    return _getCredentialIds(index)
        .map(_convertToCredentialType)
        .toList(growable: false);
  }

  Iterable<Bytes> _getCredentialIds(int? index) {
    if (index == null) return _knownCredentials;
    return _knownCredentials.elementAtOrNull(index)?.let((e) => [e]) ?? [];
  }

  CredentialType _convertToCredentialType(Bytes credentialId) {
    return CredentialType(
      type: 'public-key',
      id: b64e(credentialId),
      transports: const ['usb', 'ble', 'nfc', 'internal'],
    );
  }

  Future<RegisterResponseType> _register(String username, String displayname,
      [String? challenge,
      bool requiresResidentKey = true,
      bool requiresUserVerification = true]) async {
    final options = _opts;
    options.type = "webauthn.create";
    final entity = RegisterRequestType(
      challenge: b64e(clientDataHash(options, challenge)),
      relyingParty: RelyingPartyType(
        id: options.namespace,
        name: options.name,
      ),
      user: UserType(
        id: randomBase64String(),
        displayName: displayname,
        name: username,
      ),
      authSelectionType: AuthenticatorSelectionType(
        requireResidentKey: requiresResidentKey,
        residentKey: requiresResidentKey ? 'preferred' : 'discouraged',
        authenticatorAttachment: 'platform',
        userVerification: requiresUserVerification ? 'required' : 'preferred',
      ),
      pubKeyCredParams: [
        PubKeyCredParamType(
          type: 'public-key',
          alg: -7,
        ),
      ],
      timeout: 60000,
      attestation: 'none',
      excludeCredentials: [],
    );
    return await _auth.register(entity);
  }

  Future<AuthenticateResponseType> _authenticate(String challenge,
      [List<CredentialType>? allowedCredentials,
      bool preferImmediatelyAvailableCredentials = false,
      bool requiresUserVerification = true]) async {
    final entity = AuthenticateRequestType(
        preferImmediatelyAvailableCredentials:
            preferImmediatelyAvailableCredentials,
        relyingPartyId: _opts.namespace,
        challenge: challenge,
        timeout: 60000,
        userVerification: requiresUserVerification ? 'required' : 'preferred',
        allowCredentials: allowedCredentials,
        mediation: MediationType.Conditional);
    return await _auth.authenticate(entity);
  }

  static String buildSafeSignatureBytes(
    EthereumAddress signer,
    PassKeySignature signature,
  ) {
    // parse the passkey signature data
    final dataNo0x = _getSignatureBytes(signature);

    // Static part length in bytes
    const int signatureLengthBytes = 65;

    // Ensure signer address is 32 bytes (64 hex chars)
    String signerNo0x = signer.hexNo0x.padLeft(64, '0');

    // Convert dynamic part position to hex and pad to 32 bytes (64 hex chars)
    String dynamicPartPosition =
        signatureLengthBytes.toRadixString(16).padLeft(64, '0');

    // Convert dynamic part length to hex and pad to 32 bytes (64 hex chars)
    String dynamicPartLength =
        (dataNo0x.length ~/ 2).toRadixString(16).padLeft(64, '0');

    // Build the static part of the signature
    String staticSignature = '0x$signerNo0x${dynamicPartPosition}00';

    // Build the dynamic part with length
    // {32-bytes signature length}{bytes signature data}
    String dynamicPartWithLength = dynamicPartLength + dataNo0x;

    // Return the complete signature bytes
    return "$staticSignature$dynamicPartWithLength";
  }
}

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  String? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.challenge,
      this.type});
}

extension IterableExtension on Uint8List {
  R? let<R>(R Function(Uint8List) block) => block(this);
}

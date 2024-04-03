part of "../web3_signers_base.dart";

class HardwareSigner implements HardwareSignerInterface {
  @override
  String dummySignature =
      "0x44dcb6ead69cff6d51ce5c978db2b8539b55b2190b356afb86fe7f586a58c699d0c5fee693d4f7a6dcd638ca35d23954ee8470c807e0f948251c05ff9d989e22";

  final String _tag;

  HardwareSigner._internal(this._tag);

  factory HardwareSigner.withTag(String tag) {
    return HardwareSigner._internal(tag);
  }

  @override
  Future<P256Credential> generateKeyPair() async {
    final publicKeyBytes = await SecureP256.getPublicKey(_tag);
    final publicKey = await getPublicKeyFromBytes(publicKeyBytes.derKey);
    return P256Credential(
        _tag, publicKeyBytes.derKey, publicKeyBytes.rawKey, publicKey);
  }

  @override
  String getAddress({int? index}) {
    return _tag;
  }

  @override
  Future<Tuple<Uint256, Uint256>> getPublicKey() async {
    await _checkKey();
    final publicKeyBytes = await SecureP256.getPublicKey(_tag);

    return await getPublicKeyFromBytes(publicKeyBytes.derKey);
  }

  @override
  Future<bool> isKeyCreated() {
    return SecureP256.isKeyCreated(_tag);
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final signature = await signToP256Signature(hash);
    return signature.toUint8List();
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final signature = await signToP256Signature(hash);
    return MsgSignature(signature.r.value, signature.s.value, 0);
  }

  @override
  Future<P256Signature> signToP256Signature(Uint8List hash) async {
    await _checkKey();
    final signatureBytes = await SecureP256.sign(_tag, hash);
    final signature = getMessagingSignature(signatureBytes);

    return P256Signature(
        hash, signatureBytes, signature.item1, signature.item2);
  }

  Future<void> _checkKey() async {
    final bool isKeyCreated = await SecureP256.isKeyCreated(_tag);
    if (!isKeyCreated) {
      throw KeyPairForTagDoesNotExist(_tag);
    }
  }
}

class P256Credential {
  final String tag;
  final Uint8List credentialDer;
  final Uint8List credentialRaw;
  final Tuple<Uint256, Uint256> publicKey;

  P256Credential(
      this.tag, this.credentialDer, this.credentialRaw, this.publicKey);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tag': tag,
      'credentialDer': credentialDer.toList(),
      'credentialRaw': credentialRaw.toList(),
      'publicKeyX': publicKey.item1.toString(),
      'publicKeyY': publicKey.item2.toString(),
    };
  }

  factory P256Credential.fromMap(Map<String, dynamic> map) {
    return P256Credential(
        map['tag'] as String,
        Uint8List.fromList(List<int>.from(map['credentialDer'])),
        Uint8List.fromList(List<int>.from(map['credentialRaw'])),
        Tuple(Uint256.fromHex(map['publicKeyX'] as String),
            Uint256.fromHex(map['publicKeyY'] as String)));
  }

  String toJson() => json.encode(toMap());

  factory P256Credential.fromJson(String source) =>
      P256Credential.fromMap(json.decode(source) as Map<String, dynamic>);
}

class P256Signature {
  final Uint8List signedPayload;
  final Uint8List signatureRaw;
  final Uint256 r;
  final Uint256 s;

  P256Signature(this.signedPayload, this.signatureRaw, this.r, this.s);

  /// Converts the `P256Signature` to a `Uint8List` using the specified ABI encoding.
  ///
  /// Returns the encoded Uint8List.
  ///
  /// Example:
  /// ```dart
  /// final Uint8List encodedSig = p256Sig.toUint8List();
  /// ```
  Uint8List toUint8List() {
    return abi.encode(['uint256', 'uint256'], [r.value, s.value]);
  }
}

class KeyPairForTagDoesNotExist extends Error {
  final String tag;

  KeyPairForTagDoesNotExist(this.tag);

  @override
  String toString() {
    return 'KeyPairForTagDoesNotExist: $tag';
  }
}

class KeyPairForTagAlreadyExists extends Error {
  final String tag;

  KeyPairForTagAlreadyExists(this.tag);

  @override
  String toString() {
    return 'KeyPairForTagAlreadyExists: $tag';
  }
}

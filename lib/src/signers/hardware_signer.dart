part of "../web3_signers_base.dart";

class HardwareSigner implements HardwareSignerInterface {
  @override
  String dummySignature = "";

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
    final bool isKeyCreated = await SecureP256.isKeyCreated(_tag);
    if (!isKeyCreated) {
      throw KeyPairForTagDoesNotExist(_tag);
    }
    final publicKeyBytes = await SecureP256.getPublicKey(_tag);

    return await getPublicKeyFromBytes(publicKeyBytes.derKey);
  }

  @override
  Future<bool> isKeyCreated() {
    return SecureP256.isKeyCreated(_tag);
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final bool isKeyCreated = await SecureP256.isKeyCreated(_tag);
    if (!isKeyCreated) {
      throw KeyPairForTagDoesNotExist(_tag);
    }
    return SecureP256.sign(_tag, hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final bool isKeyCreated = await SecureP256.isKeyCreated(_tag);
    if (!isKeyCreated) {
      throw KeyPairForTagDoesNotExist(_tag);
    }
    final signatureBytes = await SecureP256.sign(_tag, hash);
    final signature = getMessagingSignature(signatureBytes);

    return MsgSignature(signature.item1.value, signature.item2.value, 0);
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

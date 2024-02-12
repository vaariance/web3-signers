part of 'utils.dart';

class SecureP256 {
  const SecureP256._();

  static Future<Uint8List> decrypt({
    required Uint8List sharedSecret,
    required SecretBox encrypted,
  }) async {
    assert(sharedSecret.isNotEmpty);
    assert(Uint8List.fromList(encrypted.nonce).lengthInBytes == 12);
    assert(encrypted.cipherText.isNotEmpty);
    final sharedX = sharedSecret.sublist(0, 32);
    final decryptedMessage256 = await FlutterAesGcm.with256bits()
        .decrypt(encrypted, secretKey: SecretKey(sharedX));
    return Uint8List.fromList(decryptedMessage256);
  }

  static Future<SecretBox> encrypt({
    required Uint8List sharedSecret,
    required Uint8List message,
  }) async {
    assert(sharedSecret.isNotEmpty);
    assert(message.isNotEmpty);
    final sharedX = sharedSecret.sublist(0, 32);
    final iv = Uint8List.fromList(randomAsU8a(12));
    final encrypted = await FlutterAesGcm.with256bits()
        .encrypt(message, secretKey: SecretKey(sharedX), nonce: iv);
    return encrypted;
  }

  static Future<P256PublicKey> getPublicKey(String tag) async {
    assert(tag.isNotEmpty);
    final raw = await SecureP256Platform.instance.getPublicKey(tag);
    // ECDSA starts with 0x04 and 65 length.
    if (raw.lengthInBytes == 65) {
      return P256PublicKey.fromRaw(raw);
    } else {
      return P256PublicKey.fromDer(raw);
    }
  }

  static Future<Uint8List> getSharedSecret(
      String tag, P256PublicKey publicKey) async {
    assert(tag.isNotEmpty);
    Uint8List rawKey = publicKey.rawKey;
    if (Platform.isAndroid) {
      if (!isDerPublicKey(rawKey, oidP256)) {
        rawKey = bytesWrapDer(rawKey, oidP256);
      }
      await BiometricMiddleware().authenticate(localizedReason: "Sign");
    }
    return SecureP256Platform.instance.getSharedSecret(tag, rawKey);
  }

  static Future<bool> isKeyCreated(String tag) async {
    assert(tag.isNotEmpty);
    return SecureP256Platform.instance.isKeyCreated(tag);
  }

  static Future<Uint8List> sign(String tag, Uint8List payload) async {
    assert(tag.isNotEmpty);
    assert(payload.isNotEmpty);
    if (Platform.isAndroid) {
      await BiometricMiddleware().authenticate(localizedReason: "Sign");
    }
    final signature = await SecureP256Platform.instance.sign(tag, payload);
    if (!isDerSignature(signature)) {
      return bytesWrapDerSignature(signature);
    }
    return signature;
  }

  static Future<bool> verify(
    Uint8List payload,
    P256PublicKey publicKey,
    Uint8List signature,
  ) {
    assert(payload.isNotEmpty);
    assert(signature.isNotEmpty);
    Uint8List rawKey = publicKey.rawKey;
    if (Platform.isAndroid && !isDerPublicKey(rawKey, oidP256)) {
      rawKey = bytesWrapDer(rawKey, oidP256);
    }
    if (!isDerSignature(signature)) {
      signature = bytesWrapDerSignature(signature);
    }
    return SecureP256Platform.instance.verify(
      payload,
      rawKey,
      signature,
    );
  }
}

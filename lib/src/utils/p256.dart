part of 'utils.dart';

@Deprecated(
    "SecureP256 is part of the hardware signer and will be removed. Please use passkeys instead")
class SecureP256 {
  const SecureP256._();

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
    String tag,
    P256PublicKey publicKey, [
    Tuple<FutureOr<void> Function(String, Uint8List)?,
            FutureOr<Uint8List>? Function(Uint8List)?>?
        hooks,
  ]) async {
    assert(tag.isNotEmpty);
    Uint8List rawKey = publicKey.rawKey;
    if (Platform.isAndroid && !isDerPublicKey(rawKey, oidP256)) {
      rawKey = bytesWrapDer(rawKey, oidP256);
    }
    hooks?.item1?.call(tag, rawKey);
    final sharedSecret =
        await SecureP256Platform.instance.getSharedSecret(tag, rawKey);
    return hooks?.item2?.call(sharedSecret) ?? sharedSecret;
  }

  static Future<bool> isKeyCreated(String tag) async {
    assert(tag.isNotEmpty);
    return SecureP256Platform.instance.isKeyCreated(tag);
  }

  static Future<Uint8List> sign(
    String tag,
    Uint8List payload, [
    Tuple<FutureOr<void> Function(String, Uint8List)?,
            FutureOr<Uint8List>? Function(Uint8List)?>?
        hooks,
  ]) async {
    assert(tag.isNotEmpty);
    assert(payload.isNotEmpty);
    hooks?.item1?.call(tag, payload);
    var signature = await SecureP256Platform.instance.sign(tag, payload);
    if (!isDerSignature(signature)) {
      signature = bytesWrapDerSignature(signature);
    }
    return hooks?.item2?.call(signature) ?? signature;
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

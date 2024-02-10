part of 'platform.dart';

/// An implementation of [SecureP256Platform] that uses method channels.
class SecureP256Channel extends SecureP256Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('web3_signers');

  @override
  Future<Uint8List> getPublicKey(String tag) async {
    final keyBytes = await methodChannel.invokeMethod(
      Methods.getPublicKey,
      {'tag': tag},
    );
    return keyBytes;
  }

  @override
  Future<bool> isKeyCreated(String tag) async {
    final created = await methodChannel.invokeMethod(
      Methods.isKeyCreated,
      {'tag': tag},
    );
    return created;
  }

  @override
  Future<Uint8List> sign(String tag, Uint8List payload) async {
    final signature = await methodChannel.invokeMethod(
      Methods.sign,
      {'tag': tag, 'payload': payload},
    );
    return signature;
  }

  @override
  Future<bool> verify(
    Uint8List payload,
    Uint8List publicKey,
    Uint8List signature,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      Methods.verify,
      {
        'payload': payload,
        'publicKey': publicKey,
        'signature': signature,
      },
    );
    return result ?? false;
  }

  @override
  Future<Uint8List> getSharedSecret(String tag, Uint8List publicKey) async {
    final result = await methodChannel.invokeMethod(
      Methods.getSharedSecret,
      {'tag': tag, 'publicKey': publicKey},
    );
    return result;
  }
}

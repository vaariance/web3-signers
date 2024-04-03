part of 'interfaces.dart';

typedef HSI = HardwareSignerInterface;

abstract class HardwareSignerInterface extends MultiSignerInterface {
  /// Generates a key pair and returns a `Future` that completes with a `P256Credential`.
  ///
  /// This function is asynchronous and returns a `Future<P256Credential>`.
  /// The `P256Credential` object represents the generated key pair.
  /// if publickey already exist for tag, does not generate new one.
  ///
  /// Example:
  /// ```dart
  /// P256Credential credential = await generateKeyPair();
  /// ```
  Future<P256Credential> generateKeyPair();

  /// Checks if a key has been created and returns a `Future` that completes with a boolean.
  ///
  /// This function is asynchronous and returns a `Future<bool>`.
  /// The boolean value indicates whether a key has been created (`true`) or not (`false`).
  ///
  /// Example:
  /// ```dart
  /// bool isCreated = await isKeyCreated();
  /// ```
  Future<bool> isKeyCreated();

  /// Gets the public key and returns a `Future` that completes with a `Tuple2<Uint256, Uint256>`.
  ///
  /// This function is asynchronous and returns a `Future<Tuple2<Uint256, Uint256>>`.
  /// The `Tuple2<Uint256, Uint256>` object represents the public key.
  ///
  /// Example:
  /// ```dart
  /// Tuple<Uint256, Uint256> publicKey = await getPublicKey();
  /// ```
  Future<Tuple<Uint256, Uint256>> getPublicKey();

  /// Signs a hash and returns a `Future` that completes with a `P256Signature`.
  ///
  /// This function is asynchronous and returns a `Future<P256Signature>`.
  /// The `P256Signature` object represents the signed hash.
  ///
  /// Example:
  /// ```dart
  /// P256Signature signature = await singToP256Signature(hash);
  /// ```
  Future<P256Signature> signToP256Signature(Uint8List hash);
}

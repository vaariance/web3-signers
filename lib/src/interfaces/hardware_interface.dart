part of 'interfaces.dart';

abstract class HardwareInterface extends MultiSignerInterface {
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
}

part of 'interfaces.dart';

typedef PSI = PasskeySignerInterface;

abstract class Authenticator implements PasskeyAuthenticator {}

abstract class PasskeySignerInterface extends MultiSignerInterface {
  /// Gets the PassKeysOptions used by the PasskeyInterface.
  PassKeysOptions get opts;

  /// Registers a new PassKeyPair.
  ///
  /// Parameters:
  /// - [username]: The name/email address associated with the PassKeyPair.
  /// - [displayname]: (Optional android 14+) display name associated with the PassKeyPair.
  /// - [challenge]: Optional challenge value. Defaults to a randomly generated challenge if not provided.
  ///
  /// Returns a Future<PassKeyPair> representing the registered PassKeyPair.
  ///
  /// Example:
  /// ```dart
  /// final pkps = PassKeySigner(options: PassKeysOptions);
  /// final passKeyPair = await pkps.register('geffy', true);
  /// ```
  Future<PassKeyPair> register(String username, String displayname,
      {String? challenge});

  /// Signs a hash using the PassKeyPair associated with the given credentialId.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [knownCredentials]: Optional credentials to be used for signing.
  ///
  /// Returns a Future<PassKeySignature> representing the PassKeySignature of the signed hash.
  ///
  /// Example:
  /// ```dart
  /// final hash = Uint8List.fromList([/* your hash bytes here */]);
  ///
  /// final pkps = PassKeySigner(options: PassKeysOptions);
  /// final passKeySignature = await pkps.signToPasskeySignature(hash);
  /// ```
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash,
      {List<CredentialType>? knownCredentials});

  /// Generates a random base64 string.
  String randomBase64String();
}

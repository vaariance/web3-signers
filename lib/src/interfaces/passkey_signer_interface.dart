part of 'interfaces.dart';

typedef PSI = PasskeySignerInterface;

abstract class Authenticator implements PasskeyAuthenticator {}

abstract class PasskeySignerInterface extends MultiSignerInterface {
  /// Gets the PassKeysOptions used by the PasskeyInterface.
  PassKeysOptions get opts;

  /// Generates the 32-byte client data hash for the given [PassKeysOptions] and optional challenge.
  ///
  /// Parameters:
  /// - [options]: PassKeysOptions containing the authentication options.
  /// - [challenge]: Optional challenge value. Defaults to a randomly generated challenge if not provided.
  ///
  /// Returns the Uint8List representation of the 32-byte client data hash.
  ///
  /// Example:
  /// ```dart
  /// final passKeysOptions = PassKeysOptions(type: 'webauthn', origin: 'https://example.com');
  /// final clientDataHash32 = clientDataHash32(passKeysOptions);
  /// ```
  Uint8List clientDataHash(PassKeysOptions options, [String? challenge]);

  /// Registers a new PassKeyPair.
  ///
  /// Parameters:
  /// - [username]: The name/email address associated with the PassKeyPair.
  /// - [displayname]: (Optional android 14+) display name associated with the PassKeyPair.
  /// - [requiresUserVerification]: A boolean indicating whether user verification is required. Defaults to true.
  /// - [requiresResidentKey]: A boolean indicating whether a resident key is required. Defaults to false.
  /// - [challenge]: Optional challenge value. Defaults to a randomly generated challenge if not provided.
  ///
  /// Returns a Future<PassKeyPair> representing the registered PassKeyPair.
  ///
  /// Example:
  /// ```dart
  /// final pkps = PassKeySigner("example", "example.com", "https://example.com");
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
  /// final pkps = PassKeySigner("example", "example.com", "https://example.com");
  /// final passKeySignature = await pkps.signToPasskeySignature(hash);
  /// ```
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash,
      {List<CredentialType>? knownCredentials});

  /// Generates a random base64 string.
  String randomBase64String();
}

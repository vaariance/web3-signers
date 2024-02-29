part of 'interfaces.dart';

typedef PSI = PasskeySignerInterface;

abstract class PasskeySignerInterface extends MultiSignerInterface {
  /// Gets the PassKeysOptions used by the PasskeyInterface.
  PassKeysOptions get opts;

  /// Gets the credential IDs used by the passkey signer.
  Set<String> get credentialIds;

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
  Uint8List clientDataHash(PassKeysOptions options, {String? challenge});

  /// Converts a List<int> credentialId to a hex string representation with a length of 32 bytes.
  ///
  /// Parameters:
  /// - [credentialId]: List of integers representing the credentialId.
  ///
  /// Returns the hex string representation of the credentialId padded to 32 bytes.
  ///
  /// Example:
  /// ```dart
  /// final credentialId = [1, 2, 3];
  /// final hexString = credentialIdToBytes32Hex(credentialId);
  /// ```
  String credentialIdToHex(List<int> credentialId);

  /// Converts an hex encoded credential with a length of 32 bytes to Uin8List.
  ///
  /// Parameters:
  /// - [credentialHex]: representing the credentialId hex encoded.
  ///
  /// Returns the bytes representation of the credentialId.
  ///
  /// Example:
  /// ```dart
  /// final credentialHex =  "0x54efBC...";
  /// final bytes = hexToCredentialId(credentialHex);
  /// ```
  Uint8List hexToCredentialId(String credentialHex);

  /// Registers a new PassKeyPair.
  ///
  /// Parameters:
  /// - [firstName]: The name associated with the PassKeyPair.
  /// - [lastName]: Optional last name associated with the PassKeyPair.
  /// - [requiresUserVerification]: A boolean indicating whether user verification is required. Defaults to true.
  ///
  /// Returns a Future<PassKeyPair> representing the registered PassKeyPair.
  ///
  /// Example:
  /// ```dart
  /// final pkps = PassKeySigner("example", "example.com", "https://example.com");
  /// final passKeyPair = await pkps.register('geffy', true);
  /// ```
  Future<PassKeyPair> register(String firstName,
      [String lastName = "", bool requiresUserVerification = true]);

  /// Signs a hash using the PassKeyPair associated with the given credentialId.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [index]: Optional index of the credentialId associated with the PassKeyPair.
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
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash, {int? index});
}

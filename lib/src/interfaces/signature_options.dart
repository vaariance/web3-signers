part of 'interfaces.dart';

/// Represents options for signature generation.
///
/// This class allows specifying a prefix to be used in the signature process.
class SignatureOptions {
  final List<int> _prefix;

  /// Gets the prefix as a Uint8List.
  ///
  /// Returns a Uint8List representation of the internal prefix.
  ///
  /// Example:
  /// ```dart
  /// final options = SignatureOptions(prefix: [1, 2, 3]);
  /// final prefixBytes = options.prefix;
  /// print(prefixBytes); // Uint8List [1, 2, 3]
  /// ```
  Uint8List get prefix => Uint8List.fromList(_prefix);

  /// Creates a new instance of SignatureOptions.
  ///
  /// Parameters:
  /// - [prefix]: An optional list of integers to be used as a prefix. Defaults to an empty list.
  ///
  /// Example:
  /// ```dart
  /// final options = SignatureOptions(prefix: [0xAB, 0xCD]);
  /// ```
  const SignatureOptions({List<int> prefix = const []}) : _prefix = prefix;
}

/// Represents options for PassKeys operations, extending SignatureOptions.
///
/// This class encapsulates various parameters required for PassKeys authentication
/// and signature processes.
class PassKeysOptions extends SignatureOptions {
  /// The relying party id or domain name.
  /// e.g variance.space
  final String namespace;

  /// The name of the relying party.
  /// e.g variance
  final String name;

  /// The origin (typically a domain) of the relying party.
  /// e.g "https://variance.space"
  final String origin;

  /// An user defined challenge string for the attestation process.
  /// if not provided, a random string will be generated
  String? challenge;

  /// An optional type identifier for the PassKeys operation.
  /// ["webauthn.create"] or ["webauthn.get"]
  String? type;

  /// The Ethereum address of the shared WebAuthn signer.
  final EthereumAddress sharedWebauthnSigner;

  /// The level of user verification required.
  ///
  /// Defaults to "required".
  final String userVerification;

  /// Indicates whether a resident key is required.
  ///
  /// Defaults to true.
  final bool requireResidentKey;

  /// Creates a new instance of PassKeysOptions.
  ///
  /// Parameters:
  /// - [prefix]: An optional prefix inherited from SignatureOptions.
  /// - [namespace]: The namespace for the PassKeys operation.
  /// - [name]: The name associated with the PassKeys operation.
  /// - [origin]: The origin (typically a domain) for the PassKeys operation.
  /// - [sharedWebauthnSigner]: The Ethereum address of the shared WebAuthn signer.
  /// - [userVerification]: The level of user verification required. Defaults to "required".
  /// - [requireResidentKey]: Indicates whether a resident key is required. Defaults to true.
  /// - [challenge]: An optional challenge string for the authentication process.
  /// - [type]: An optional type identifier for the PassKeys operation.
  ///
  /// Example:
  /// ```dart
  /// final options = PassKeysOptions(
  ///   namespace: 'com.example',
  ///   name: 'ExampleApp',
  ///   origin: 'https://example.com',
  ///   sharedWebauthnSigner: EthereumAddress.fromHex('0x1234...'),
  ///   challenge: 'randomChallenge123',
  ///   type: 'webauthn'
  /// );
  /// ```
  PassKeysOptions(
      {super.prefix,
      required this.namespace,
      required this.name,
      required this.origin,
      required this.sharedWebauthnSigner,
      this.userVerification = "required",
      this.requireResidentKey = true,
      this.challenge,
      this.type});
}

/// Represents a FCL (Flow Client Library) signature.
///
/// This class encapsulates the components of an FCL signature: the static signature,
/// the length of the dynamic part, and the data itself.
class FCLSignature {
  /// The static part of the signature.
  final Uint8List staticSignature;

  /// The length of the dynamic part of the signature.
  final Uint8List dynamicPartLength;

  /// The data component of the signature.
  final Uint8List data;

  /// Creates a new instance of FCLSignature.
  ///
  /// Parameters:
  /// - [staticSignature]: The static part of the signature as a Uint8List.
  /// - [dynamicPartLength]: The length of the dynamic part as a Uint8List.
  /// - [data]: The data (dynamic) component of the signature as a Uint8List.
  ///
  /// Example:
  /// ```dart
  /// final signature = FCLSignature(
  ///   Uint8List.fromList([1, 2, 3]),
  ///   Uint8List.fromList([0, 4]),
  ///   Uint8List.fromList([5, 6, 7, 8])
  /// );
  /// ```
  const FCLSignature(this.staticSignature, this.dynamicPartLength, this.data);

  /// Converts the FCLSignature to a single Uint8List.
  ///
  /// This method concatenates the staticSignature, dynamicPartLength, and data
  /// into a single Uint8List.
  ///
  /// Returns a Uint8List representing the entire signature.
  ///
  /// Example:
  /// ```dart
  /// final signature = FCLSignature(...);
  /// final bytes = signature.toUint8List();
  /// ```
  Uint8List toUint8List() {
    return staticSignature.concat(dynamicPartLength).concat(data);
  }

  /// Returns a hexadecimal string representation of the signature.
  ///
  /// This method converts the entire signature to a hexadecimal string.
  ///
  /// Returns a String containing the hexadecimal representation of the signature.
  ///
  /// Example:
  /// ```dart
  /// final signature = FCLSignature(...);
  /// print(signature.toString()); // Prints something like "0x0123456789abcdef..."
  /// ```
  @override
  String toString() {
    return hexlify(toUint8List());
  }
}

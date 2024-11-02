// ignore_for_file: constant_identifier_names

part of 'interfaces.dart';

typedef MSI = MultiSignerInterface;

/// An interface for a multi-signer, allowing signing of data and returning the result.
///
/// the multi-signer interface provides a uniform interface for accessing signer address and signing
/// messages in the Ethereum context. This allows for flexibility in creating different implementations
/// of multi-signers while adhering to a common interface.
/// interfaces include: [PrivateKeySigner], [PassKeySigner] and [EOAWallet]
abstract class MultiSignerInterface {
  /// The dummy signature is a valid signature that can be used for testing purposes.
  /// specifically, this will be used to simulate user operation on the entrypoint.
  /// You must specify a dummy signature that matches your transaction signature standard.
  String getDummySignature();

  /// Generates an Ethereum address of the signer.
  ///
  /// Parameters:
  /// - [index] optianal index to pass to the function.
  ///
  /// Example:
  /// ```dart
  /// final address = getAddress();
  ///
  /// // assuming signer is HD wallet
  /// final address = getAddress(3); // gets the address for account derived at position 3
  /// ```
  String getAddress({int? index});

  /// Signs the provided [hash] using the personal sign method.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [index] optianal value to pass to the function.
  ///   - can be index to specify which privatekey to use for signing (required for HD wallets).
  ///
  /// Example:
  /// ```dart
  /// final hash = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  /// final signature = await personalSign(hash); // assuming no data is required for actual signing
  ///
  /// // assuming signer is a HD wallet, 'index' of account can be passed
  /// final signature = await personalSign(hash, 0);
  /// ```

  Future<Uint8List> personalSign(Uint8List hash, {int? index});

  /// Signs the provided [hash] using elliptic curve (EC) signatures and returns the r and s values.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [index] optianal value to pass to the function.
  ///   - can be index to specify which privatekey to use for signing (required for HD wallets).
  ///
  /// Example:
  /// ```dart
  /// final hash = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  /// final signature = await signToEc(hash);
  ///
  /// // assuming signer is a HD wallet, 'index' of account can be passed
  /// final signature = await signToEc(hash, 0);
  /// ```
  Future<MsgSignature> signToEc(Uint8List hash, {int? index});

  /// Signs typed data according to EIP-712 standard.
  ///
  /// Parameters:
  /// - [jsonData]: The typed data in JSON format that needs to be signed.
  /// - [version]: The version of the typed data standard to use for signing.
  /// - [index] optianal value to pass to the function.
  ///   - can be index to specify which privatekey to use for signing (required for HD wallets).
  ///
  /// Example:
  /// ```dart
  /// final jsonData = '''
  ///   {
  ///     "types": {
  ///       "EIP712Domain": [...],
  ///       "Mail": [...]
  ///     },
  ///     "primaryType": "Mail",
  ///     "domain": {...},
  ///     "message": {...}
  ///   }
  /// ''';
  /// final signature = await signTypedData(jsonData, TypedDataVersion.V4);
  /// ```
  Future<Uint8List> signTypedData(String jsonData, TypedDataVersion version,
      {int? index});

  /// {@template isValidSignature}
  /// Verifies a personal signature against a hash.
  ///
  /// Parameters:
  /// - [hash]: The original hash that was signed.
  /// - [signature]: The signature to verify against the hash.
  /// - [signer]: The signer address or public key to verify the signature against.
  /// {@endtemplate}
  ///
  /// The signer parameter is generic [T] to support different signer types.
  /// This is used to specify the publickey to verify the signature against.
  /// and can be the signer address or passkey keypair.
  /// The signature parameter is also generic [U] to support different signature formats.
  /// Returns [ERC1271IsValidSignatureResponse] magic value.
  ///
  /// Example:
  /// ```dart
  /// final hash = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  /// final signature = await personalSign(hash);
  /// final isValid = await isValidSignature<bool, Uint8List>(hash, signature);
  /// ```
  Future<ERC1271IsValidSignatureResponse> isValidSignature<T, U>(
      Uint8List hash, U signature, T signer);
}

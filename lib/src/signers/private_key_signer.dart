part of '../web3_signers_base.dart';

class PrivateKeySigner implements MultiSignerInterface {
  final Wallet _credential;

  final SignatureOptions _options;

  /// Creates a PrivateKeySigner instance using the provided EthPrivateKey.
  ///
  /// Parameters:
  /// - [privateKey]: The EthPrivateKey used to create the PrivateKeySigner.
  /// - [password]: The password for encrypting the private key.
  /// - [random]: The Random instance for generating random values.
  /// - [scryptN]: Scrypt parameter N (CPU/memory cost) for key derivation. Defaults to 8192.
  /// - [p]: Scrypt parameter p (parallelization factor) for key derivation. Defaults to 1.
  ///
  /// Example:
  /// ```dart
  /// final ethPrivateKey = EthPrivateKey.fromHex('your_private_key_hex');
  /// final password = 'your_password';
  /// final random = Random.secure();
  /// final privateKeySigner = PrivateKeySigner.create(ethPrivateKey, password, random);
  /// ```
  PrivateKeySigner.create(
      EthPrivateKey privateKey, String password, Random random,
      {SignatureOptions options = const SignatureOptions(),
      int scryptN = 8192,
      int p = 1})
      : _credential = Wallet.createNew(privateKey, password, random,
            scryptN: scryptN, p: p),
        _options = options;

  /// Creates a PrivateKeySigner instance with a randomly generated EthPrivateKey.
  ///
  /// Parameters:
  /// - [password]: The password for encrypting the private key.
  ///
  /// Example:
  /// ```dart
  /// final password = 'your_password';
  /// final privateKeySigner = PrivateKeySigner.createRandom(password);
  /// ```
  factory PrivateKeySigner.createRandom(String password,
      [SignatureOptions options = const SignatureOptions()]) {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    final credential = Wallet.createNew(privateKey, password, random);
    return PrivateKeySigner._internal(credential, options);
  }

  /// Creates a PrivateKeySigner instance from JSON representation.
  ///
  /// Parameters:
  /// - [source]: The JSON representation of the wallet.
  /// - [password]: The password for decrypting the private key.
  ///
  /// Example:
  /// ```dart
  /// final sourceJson = '{"privateKey": "your_private_key_encrypted", ...}';
  /// final password = 'your_password';
  /// final privateKeySigner = PrivateKeySigner.fromJson(sourceJson, password);
  /// ```
  factory PrivateKeySigner.fromJson(String source, String password,
          [SignatureOptions options = const SignatureOptions()]) =>
      PrivateKeySigner._internal(Wallet.fromJson(source, password), options);

  PrivateKeySigner._internal(this._credential, this._options);

  /// Returns the Ethereum address associated with the PrivateKeySigner.
  EthereumAddress get address => _credential.privateKey.address;

  /// Returns the public key associated with the PrivateKeySigner.
  Uint8List get publicKey => _credential.privateKey.encodedPublicKey;

  @override
  String getAddress({int? index}) {
    return address.hex;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    return _options.prefix
        .concat(_credential.privateKey.signPersonalMessageToUint8List(hash));
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    return _credential.privateKey.signToEcSignature(hash);
  }

  @override
  String getDummySignature() =>
      "${hexlify(_options.prefix)}fffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

  String toJson() => _credential.toJson();
}

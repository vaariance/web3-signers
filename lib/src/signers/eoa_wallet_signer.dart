part of '../web3_signers_base.dart';

class EOAWalletSigner with SecureStorageMixin implements EOAInterface {
  final String _mnemonic;

  final String _seed;

  late final EthereumAddress zerothAddress;

  @override
  String dummySignature =
      "0xfffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

  /// Creates a new EOA wallet signer instance by generating a random mnemonic phrase.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.createWallet();
  /// ```
  factory EOAWalletSigner.createWallet() {
    return EOAWalletSigner.recoverAccount(bip39.generateMnemonic());
  }

  /// Recovers an EOA wallet signer instance from a given mnemonic phrase.
  ///
  /// Parameters:
  /// - [mnemonic]: The mnemonic phrase used for recovering the HD wallet signer.
  ///
  /// Example:
  /// ```dart
  /// final mnemonicPhrase = 'word1 word2 word3 ...'; // Replace with an actual mnemonic phrase
  /// final recoveredSigner = HDWalletSigner.recoverAccount(mnemonicPhrase);
  /// ```

  factory EOAWalletSigner.recoverAccount(String mnemonic) {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final signer = EOAWalletSigner._internal(seed: seed, mnemonic: mnemonic);
    signer.zerothAddress = signer._add(seed, 0);
    return signer;
  }

  EOAWalletSigner._internal({required String seed, required String mnemonic})
      : _seed = seed,
        _mnemonic = mnemonic {
    assert(seed.isNotEmpty, "seed cannot be empty");
  }

  @override
  EthereumAddress addAccount(int index) {
    return _add(_seed, index);
  }

  @override
  String exportMnemonic() {
    return _getMnemonic();
  }

  @override
  String exportPrivateKey(int index) {
    final ethPrivateKey = _getPrivateKey(index);
    Uint8List privKey = ethPrivateKey.privateKey;
    bool rlz = shouldRemoveLeadingZero(privKey);
    if (rlz) {
      privKey = privKey.sublist(1);
    }
    return hexlify(privKey);
  }

  @override
  String getAddress({int? index}) {
    return _getEthereumAddress(index: index ?? 0).hex;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return privKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return privKey.signToEcSignature(hash);
  }

  @override
  SecureStorageMiddleware withSecureStorage(FlutterSecureStorage secureStorage,
      {Authentication? authMiddleware}) {
    return SecureStorageMiddleware(secureStorage,
        authMiddleware: authMiddleware, credential: _getMnemonic());
  }

  EthereumAddress _add(String seed, int index) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address;
  }

  EthPrivateKey _deriveEthPrivKey(String key) {
    final ethPrivateKey = EthPrivateKey.fromHex(key);
    return ethPrivateKey;
  }

  bip44.ExtendedPrivateKey _deriveHdKey(String seed, int idx) {
    final path = "m/44'/60'/0'/0/$idx";
    final chain = bip44.Chain.seed(seed);
    final hdKey = chain.forPath(path) as bip44.ExtendedPrivateKey;
    return hdKey;
  }

  EthereumAddress _getEthereumAddress({int index = 0}) {
    bip44.ExtendedPrivateKey hdKey = _getHdKey(index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address;
  }

  bip44.ExtendedPrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  String _getMnemonic() {
    return _mnemonic;
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    final privateKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privateKey;
  }

  /// Loads an EOA wallet signer instance from secure storage using the provided [SecureStorageRepository].
  ///
  /// Parameters:
  /// - [storageMiddleware]: The secure storage repository used to retrieve the EOA wallet credentials.
  /// - [options]: Optional authentication operation options. Defaults to `null`.
  ///
  /// Returns a `Future` that resolves to a `HDWalletSigner` instance if successfully loaded, or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final loadedSigner = await HDWalletSigner.loadFromSecureStorage(
  ///    SecureStorageMiddleware(),
  /// );
  /// ```
  static Future<EOAWalletSigner?> loadFromSecureStorage(
      SecureStorageRepository storageMiddleware,
      {StorageOptions? options}) {
    return storageMiddleware
        .readCredential(SignerType.eoaWallet, options: options)
        .then((value) =>
            value != null ? EOAWalletSigner.recoverAccount(value) : null);
  }
}

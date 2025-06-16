part of '../web3_signers_base.dart';

class EOAWallet implements EOAWalletInterface {
  final List<String> _mnemonic;

  final Uint8List _seed;

  final SignatureOptions _options;

  /// Creates a new EOA wallet signer instance by generating a random mnemonic phrase.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.createWallet(); // defaults to 12 words
  ///
  /// // create a 24 word phrase wallet
  /// final walletSigner24 = HDWalletSigner.createWallet(WordLength.word_24); // defaults to 12 words
  /// ```
  factory EOAWallet.createWallet([
    WordLength wordLenth = WordLength.word_12,
    SignatureOptions options = const SignatureOptions(),
  ]) {
    final wordStrength = wordLenth.wordsStrength;
    final phrase = generateMnemonic(strength: wordStrength);
    return EOAWallet.recoverAccount(phrase.join(' '), options);
  }

  /// Recovers an EOA wallet signer instance from a given mnemonic phrase.
  ///
  /// Parameters:
  /// - [mnemonic]: The mnemonic phrase used for recovering the HD wallet signer.
  /// - [options]: The signature options used to construct final signature.
  ///
  /// Example:
  /// ```dart
  /// final mnemonicPhrase = 'word1 word2 word3 ...'; // Replace with an actual mnemonic phrase
  /// final recoveredSigner = HDWalletSigner.recoverAccount(mnemonicPhrase);
  /// ```
  factory EOAWallet.recoverAccount(
    String mnemonic, [
    SignatureOptions options = const SignatureOptions(),
  ]) {
    final List<String> words = mnemonic.split(' ');
    final seed = mnemonicToSeed(words);
    final signer = EOAWallet._internal(
      seed: seed,
      mnemonic: words,
      options: options,
    );
    return signer;
  }

  EOAWallet._internal({
    required Uint8List seed,
    required List<String> mnemonic,
    required SignatureOptions options,
  }) : _seed = seed,
       _mnemonic = mnemonic,
       _options = options {
    assert(seed.isNotEmpty, "seed cannot be empty");
  }

  @override
  EthereumAddress addAccount(int index) {
    return _add(_seed, index);
  }

  @override
  String exportMnemonic() {
    return _mnemonic.join(' ');
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
    return _getEthereumAddress(index ?? 0).with0x;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return _options.prefix.concat(privKey.signPersonalMessageToUint8List(hash));
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return privKey.signToEcSignature(hash);
  }

  @override
  String getDummySignature() =>
      "${hexlify(_options.prefix)}ee2eb84d326637ae9c4eb2febe1f74dc43e6bb146182ef757ebf0c7c6e0d29dc2530d8b5ec0ab1d0d6ace9359e1f9b117651202e8a7f1f664ce6978621c7d5fb1b";

  EthereumAddress _add(Uint8List seed, int index) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.key);
    return privKey.address;
  }

  EthPrivateKey _deriveEthPrivKey(BigInt key) {
    final ethPrivateKey = EthPrivateKey.fromInt(key);
    return ethPrivateKey;
  }

  ExtendedPrivateKey _deriveHdKey(Uint8List seed, int idx) {
    final path = "m/44'/60'/0'/0/$idx";
    final chain = ExtendedPrivateKey.master(
      seed,
      List<int>.from([0x04, 0x88, 0xAD, 0xE4]),
    );
    return chain.forPath(path) as ExtendedPrivateKey;
  }

  EthereumAddress _getEthereumAddress(int index) {
    return _getPrivateKey(index).address;
  }

  ExtendedPrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    return _deriveEthPrivKey(hdKey.key);
  }

  @override
  Future<Uint8List> signTypedData(
    TypedMessage jsonData,
    TypedDataVersion version, {
    int? index,
  }) {
    final hash = hashTypedData(typedData: jsonData, version: version);
    return personalSign(hash, index: index);
  }

  @override
  Future<ERC1271IsValidSignatureResponse> isValidSignature<T, U>(
    Uint8List hash,
    U signature,
    T address,
  ) {
    require(
      signature is Uint8List || signature is MsgSignature,
      'Signature must be of type Uint8List or MsgSignature',
    );
    require(
      address is EthereumAddress,
      'Address must be of type EthereumAddress',
    );
    address as EthereumAddress;
    if (signature is Uint8List) {
      return Future.value(isValidPersonalSignature(hash, signature, address));
    } else {
      final signer = ecRecover(keccak256(hash), signature as MsgSignature);
      return Future.value(
        ERC1271IsValidSignatureResponse.isValid(
          publicKeyToAddress(signer).eq(address.value),
        ),
      );
    }
  }
}

enum WordLength {
  word_12(128),
  word_24(256);

  final int wordsStrength;

  const WordLength(this.wordsStrength);
}

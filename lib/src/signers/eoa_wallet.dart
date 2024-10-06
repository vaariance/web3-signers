part of '../web3_signers_base.dart';

class EOAWallet implements EOAWalletInterface {
  final Mnemonic _mnemonic;

  final List<int> _seed;

  /// Creates a new EOA wallet signer instance by generating a random mnemonic phrase.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.createWallet(); // defaults to 12 words
  ///
  /// // create a 24 word phrase wallet
  /// final walletSigner24 = HDWalletSigner.createWallet(WordLength.word_24); // defaults to 12 words
  /// ```
  factory EOAWallet.createWallet([WordLength wordLenth = WordLength.word_12]) {
    final generator = Bip39MnemonicGenerator();
    final Bip39WordsNum wordNumber = wordLenth.wordsNum;
    final phrase = generator.fromWordsNumber(wordNumber);
    return EOAWallet.recoverAccount(phrase.toStr());
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
  factory EOAWallet.recoverAccount(String mnemonic) {
    final Mnemonic words = Mnemonic.fromString(mnemonic);
    final seed = Bip39SeedGenerator(words).generate();
    final signer = EOAWallet._internal(seed: seed, mnemonic: words);
    return signer;
  }

  EOAWallet._internal({required List<int> seed, required Mnemonic mnemonic})
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
    return _mnemonic.toStr();
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
  String getDummySignature<T>({required String prefix, T? getOptions}) =>
      "${prefix}fffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

  EthereumAddress _add(List<int> seed, int index) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.key.toHex());
    return privKey.address;
  }

  EthPrivateKey _deriveEthPrivKey(String key) {
    final ethPrivateKey = EthPrivateKey.fromHex(key);
    return ethPrivateKey;
  }

  Bip44PrivateKey _deriveHdKey(List<int> seed, int idx) {
    final path = "m/44'/60'/0'/0/$idx";
    final chain = Bip44.fromSeed(seed, Bip44Coins.ethereum);
    final privKey = chain.bip32.derivePath(path).privateKey;
    return Bip44PrivateKey(privKey, chain.coinConf);
  }

  EthereumAddress _getEthereumAddress({int index = 0}) {
    Bip44PrivateKey hdKey = _getHdKey(index);
    final privKey = _deriveEthPrivKey(hdKey.key.toHex());
    return privKey.address;
  }

  Bip44PrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    final privateKey = _deriveEthPrivKey(hdKey.key.toHex());
    return privateKey;
  }
}

enum WordLength {
  word_12(Bip39WordsNum.wordsNum12),
  word_24(Bip39WordsNum.wordsNum24);

  final Bip39WordsNum wordsNum;

  const WordLength(this.wordsNum);
}

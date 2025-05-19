part of '../web3_signers_base.dart';

class EOAWallet implements EOAWalletInterface {
  final Mnemonic _mnemonic;

  final List<int> _seed;

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
    final generator = Bip39MnemonicGenerator();
    final Bip39WordsNum wordNumber = wordLenth.wordsNum;
    final phrase = generator.fromWordsNumber(wordNumber);
    return EOAWallet.recoverAccount(phrase.toStr(), options);
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
    final Mnemonic words = Mnemonic.fromString(mnemonic);
    final seed = Bip39SeedGenerator(words).generate();
    final signer = EOAWallet._internal(
      seed: seed,
      mnemonic: words,
      options: options,
    );
    return signer;
  }

  EOAWallet._internal({
    required List<int> seed,
    required Mnemonic mnemonic,
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
    return _getEthereumAddress(index ?? 0).hex;
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

  EthereumAddress _getEthereumAddress(int index) {
    return _getPrivateKey(index).address;
  }

  Bip44PrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    return _deriveEthPrivKey(hdKey.key.toHex());
  }

  @override
  Future<Uint8List> signTypedData(
    String jsonData,
    TypedDataVersion version, {
    int? index,
  }) {
    final hash = TypedDataUtil.hashMessage(
      jsonData: jsonData,
      version: version,
    );
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
          EthereumAddress.fromPublicKey(signer).hex == address.hex,
        ),
      );
    }
  }
}

enum WordLength {
  word_12(Bip39WordsNum.wordsNum12),
  word_24(Bip39WordsNum.wordsNum24);

  final Bip39WordsNum wordsNum;

  const WordLength(this.wordsNum);
}

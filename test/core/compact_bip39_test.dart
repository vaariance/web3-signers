import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  test('mnemonicToPrivateKey produces correct keys (MetaMask path)', () {
    const mnemonic =
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    final expectedKeyHex =
        "1ab42cc412b618bdea3a599e3c9bae199ebf030895b039e9db1e30dafb12b727";

    final derivedKey = mnemonicToPrivateKey(mnemonic);

    final derivedKeyHex = bytesToHex(derivedKey);

    expect(derivedKeyHex, equals(expectedKeyHex));
  });

  test('mnemonicToPrivateKey respects explicit derivation path', () {
    const mnemonic =
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    // Explicitly pass the standard path, should match the default result.
    final expectedKeyHex =
        "1ab42cc412b618bdea3a599e3c9bae199ebf030895b039e9db1e30dafb12b727";

    final derivedKey = mnemonicToPrivateKey(mnemonic, "m/44'/60'/0'/0/0");
    final derivedKeyHex = bytesToHex(derivedKey);

    expect(derivedKeyHex, equals(expectedKeyHex));
  });

  test('mnemonicToSeed produces correct bip39 seed', () {
    const mnemonic =
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    // Expected seed from iancoleman/bip39
    const expectedSeedHex =
        "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4";

    final seed = mnemonicToSeed(mnemonic);
    final seedHex = bytesToHex(seed);

    expect(seedHex, equals(expectedSeedHex));
  });

  test('generates correct 24 words mnemonic', () {
    final mnemonic = generateMnemonic(WordLength.word_24);
    final words = mnemonic.split(' ');
    expect(words.length, equals(24));
  });

  test('generates correct 12 words mnemonic', () {
    final mnemonic = generateMnemonic(WordLength.word_12);
    final words = mnemonic.split(' ');
    expect(words.length, equals(12));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  test(
    'mnemonicToPrivateKey produces correct keys (MetaMask path) after further refactor',
    () {
      const mnemonic =
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
      final expectedKeyHex =
          "1ab42cc412b618bdea3a599e3c9bae199ebf030895b039e9db1e30dafb12b727";

      // Note: The function name was changed by user to mnemonicToPrivateKey in previous edits
      final derivedKey = mnemonicToPrivateKey(mnemonic);

      final derivedKeyHex =
          derivedKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      expect(derivedKeyHex, equals(expectedKeyHex));
    },
  );
}

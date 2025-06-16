import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'dart:typed_data';

void main() {
  group('EOAWallet Tests', () {
    late EOAWallet wallet;
    late String mnemonic;
    late SignatureOptions customOptions;
    final SignatureOptions defaultOptions = const SignatureOptions();
    final Uint8List customPrefix = Uint8List.fromList([0x12, 0x34, 0x56, 0x78]);

    setUp(() {
      // Create a new EOAWallet before each test with default options
      wallet = EOAWallet.createWallet();

      // Save the mnemonic for reuse
      mnemonic = wallet.exportMnemonic();

      // Create custom SignatureOptions with a custom prefix
      customOptions = SignatureOptions(prefix: customPrefix);
    });

    test('Create Wallet with Default Word Length', () {
      expect(wallet, isA<EOAWallet>());
      final mnemonicWords = wallet.exportMnemonic().split(' ');
      expect(mnemonicWords.length, equals(12)); // Default is 12 words
    });

    test('Create Wallet with 24 Word Length', () {
      final wallet24 = EOAWallet.createWallet(WordLength.word_24);
      expect(wallet24, isA<EOAWallet>());
      final mnemonicWords = wallet24.exportMnemonic().split(' ');
      expect(mnemonicWords.length, equals(24));
    });

    test('Export Mnemonic', () {
      final exportedMnemonic = wallet.exportMnemonic();
      expect(exportedMnemonic, isA<String>());
      expect(exportedMnemonic.split(' ').length, equals(12));
    });

    test('Recover Wallet from Mnemonic', () {
      final recoveredWallet = EOAWallet.recoverAccount(mnemonic);
      expect(recoveredWallet.exportMnemonic(), equals(mnemonic));
      expect(recoveredWallet.getAddress(), equals(wallet.getAddress()));
    });

    test('Get Address', () {
      final address = wallet.getAddress();
      expect(address, isA<String>());
      expect(address.startsWith('0x'), isTrue);
      expect(address.length, equals(42));
    });

    test('Add Account', () {
      final index = 1;
      final newAccountAddress = wallet.addAccount(index);
      expect(newAccountAddress, isA<EthereumAddress>());
      expect(newAccountAddress.with0x.startsWith('0x'), isTrue);
      expect(newAccountAddress.with0x.length, equals(42));

      // Check that the address is different from the default account
      expect(newAccountAddress.with0x, isNot(equals(wallet.getAddress())));
    });

    test('Export Private Key', () {
      final index = 0;
      final privateKey = wallet.exportPrivateKey(index);
      expect(privateKey, isA<String>());
      expect(
        privateKey.length,
        equals(66),
      ); // Private key is 32 bytes => 64 hex chars + '0x'
    });

    test('Export Private Key for Account Index', () {
      final index = 1;
      final privateKey = wallet.exportPrivateKey(index);
      expect(privateKey, isA<String>());
      expect(privateKey.length, equals(66));
    });

    test('Personal Sign with Default Prefix', () async {
      final message = Uint8List.fromList(List.generate(32, (index) => index));
      final signature = await wallet.personalSign(message);

      expect(signature, isA<Uint8List>());

      // Access the prefix from the wallet's options
      final prefix = defaultOptions.prefix;
      expect(signature.sublist(0, prefix.length), equals(prefix));

      // Verify the signature length (prefix + 65 bytes for ECDSA signature)
      final expectedSignatureLength = prefix.length + 65;
      expect(signature.length, equals(expectedSignatureLength));
    });

    test('Personal Sign with Custom Prefix', () async {
      // Create a wallet with custom options
      final customWallet = EOAWallet.recoverAccount(mnemonic, customOptions);

      final message = Uint8List.fromList(List.generate(32, (index) => index));
      final signature = await customWallet.personalSign(message);

      expect(signature, isA<Uint8List>());

      // Access the prefix from the custom wallet's options
      final prefix = customOptions.prefix;
      expect(signature.sublist(0, prefix.length), equals(prefix));

      // Verify the signature length
      final expectedSignatureLength = prefix.length + 65;
      expect(signature.length, equals(expectedSignatureLength));
    });

    test('Get Dummy Signature with Default Prefix', () {
      final dummySignature = wallet.getDummySignature();

      expect(dummySignature, isA<String>());
      expect(dummySignature.startsWith('0x'), isTrue);

      // Access the prefix and convert it to hex
      final prefixHex = hexlify(defaultOptions.prefix);
      expect(dummySignature.startsWith(prefixHex), isTrue);

      expect(dummySignature.length, equals(prefixHex.length + 130));
    });

    test('Get Dummy Signature with Custom Prefix', () {
      final customWallet = EOAWallet.recoverAccount(mnemonic, customOptions);

      final dummySignature = customWallet.getDummySignature();

      expect(dummySignature, isA<String>());
      expect(dummySignature.startsWith('0x'), isTrue);

      final prefixHex = hexlify(customOptions.prefix);
      expect(dummySignature.startsWith(prefixHex), isTrue);

      // Calculate expected length
      final prefixHexLength = customOptions.prefix.length * 2;
      final totalExpectedLength = 2 + prefixHexLength + (130);

      expect(dummySignature.length, equals(totalExpectedLength));
    });

    test('Sign to EC', () async {
      final message = Uint8List.fromList(List.generate(32, (index) => index));
      final msgSignature = await wallet.signToEc(message);

      expect(msgSignature, isA<MsgSignature>());

      // Verify that r and s are 256-bit numbers and v is 27 or 28
      expect(msgSignature.r.bitLength, lessThanOrEqualTo(256));
      expect(msgSignature.s.bitLength, lessThanOrEqualTo(256));
      expect(msgSignature.v, anyOf(equals(27), equals(28)));
    });

    test('Derive Addresses at Different Indices', () {
      final address0 = wallet.getAddress(index: 0);
      final address1 = wallet.getAddress(index: 1);
      final address2 = wallet.getAddress(index: 2);

      expect(address0, isNot(equals(address1)));
      expect(address0, isNot(equals(address2)));
      expect(address1, isNot(equals(address2)));
    });

    test('Multiple Accounts Generation', () {
      final addresses = <String>[];
      for (int i = 0; i < 5; i++) {
        final address = wallet.getAddress(index: i);
        expect(addresses.contains(address), isFalse);
        addresses.add(address);
      }
      expect(addresses.length, equals(5));
    });

    test('Consistency Between Exported Private Key and Address', () {
      final index = 0;
      final privateKeyHex = wallet.exportPrivateKey(index);
      final privateKey = EthPrivateKey.fromHex(privateKeyHex);
      final addressFromPrivateKey = privateKey.address.with0x;
      final addressFromWallet = wallet.getAddress(index: index);
      expect(addressFromPrivateKey, equals(addressFromWallet));
    });

    test('EC Sign Verification', () async {
      final message = Uint8List.fromList(utf8.encode('Verify this message'));
      final signature = await wallet.signToEc(message);
      final address = wallet.getAddress();
      final isValid = await wallet.isValidSignature(
        message,
        signature,
        Address.fromHex(address),
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });

    test("isValidSignature verification", () async {
      final hash = Uint8List(32);
      final signature = await wallet.personalSign(hash);
      final address = wallet.getAddress();
      final isValid = await wallet.isValidSignature(
        hash,
        signature,
        Address.fromHex(address),
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });
  });
}

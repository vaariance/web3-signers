import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:web3_signers/web3_signers.dart';

import 'constant.dart';

void main() {
  group('PrivateKeySigner Tests', () {
    late PrivateKeySigner signer;
    final password = 'testPassword123';

    setUp(() {
      // Create a new PrivateKeySigner before each test
      signer = PrivateKeySigner.createRandom(password);
    });

    test('Create PrivateKeySigner with random key', () {
      expect(signer, isA<PrivateKeySigner>());
      expect(signer.address, isA<EthereumAddress>());
      expect(signer.publicKey, isA<Uint8List>());
    });

    test('Create PrivateKeySigner from existing key', () {
      final privateKey = EthPrivateKey.createRandom(Random.secure());
      final customSigner =
          PrivateKeySigner.create(privateKey, password, Random.secure());

      expect(customSigner, isA<PrivateKeySigner>());
      expect(customSigner.address, equals(privateKey.address));
    });

    test('Get address', () {
      final address = signer.getAddress();
      expect(address, isA<String>());
      expect(address.toLowerCase().startsWith('0x'), isTrue);
      expect(address.length, equals(42));
    });

    test('Personal sign', () async {
      final hash = Uint8List.fromList(List.generate(32, (index) => index));
      final signature = await signer.personalSign(hash);

      expect(signature, isA<Uint8List>());
      expect(signature.length, equals(65));
    });

    test('Sign to EC', () async {
      final hash = Uint8List.fromList(List.generate(32, (index) => index));
      final signature = await signer.signToEc(hash);

      expect(signature, isA<MsgSignature>());
    });

    test('Get dummy signature', () {
      final dummySignature = signer.getDummySignature();
      expect(dummySignature, isA<String>());
      expect(dummySignature.toLowerCase().startsWith('0x'), isTrue);
      expect(dummySignature.length, equals(132));
    });

    test('To and from JSON', () {
      final json = signer.toJson();
      expect(json, isA<String>());

      final recoveredSigner = PrivateKeySigner.fromJson(json, password);
      expect(recoveredSigner, isA<PrivateKeySigner>());
      expect(recoveredSigner.address, equals(signer.address));
    });

    test("isValidSignature", () async {
      final hash = Uint8List.fromList(List.generate(32, (index) => index));
      final signature = await signer.personalSign(hash);

      final isValid =
          await signer.isValidSignature(hash, signature, signer.address);
      expect(isValid, equals(ERC1271IsValidSignatureResponse.sucess));
    });

    test("signed typed data v4 isValidSignature", () async {
      final hash = TypedDataUtil.hashMessage(
          jsonData: jsonData, version: TypedDataVersion.V4);
      final signature =
          await signer.signTypedData(jsonData, TypedDataVersion.V4);
      final isValid =
          await signer.isValidSignature(hash, signature, signer.address);
      expect(isValid, equals(ERC1271IsValidSignatureResponse.sucess));
    });
  });
}

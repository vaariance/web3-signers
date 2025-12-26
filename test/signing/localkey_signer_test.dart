import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3_signers/src/utils/enums.dart';
import 'package:web3dart/web3dart.dart'
    show hexToBytes, privateKeyBytesToPublic;
import 'package:eip712/eip712.dart';
import '../__test_utils__/keys/secp256k1_keys.dart';
import '../__test_utils__/fixtures/constants.dart';

void main() {
  group('LocalKeySigner', () {
    test('initializes from raw private key', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      expect(signer.getAddress(), equals(validAddress));
      expect(signer.kind, equals(SignerType.localKey));
    });

    test('initializes from mnemonic', () {
      final signer = LocalKeySigner.fromMnemonic(validMnemonic);
      expect(signer.getAddress(), equals(validMnemonicAddress));
    });

    test('signer is a LocalKeySigner by kind', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      expect(signer.kind, equals(SignerType.localKey));
    });

    test('is compatible with EIP7702 signer', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final ethKey = signer.ethPrivateKey;
      expect(ethKey.privateKey, equals(hexToBytes(validPrivateKey)));
    });

    test('returns a valid public key for the signer', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final pubKey = signer.publicKey;
      expect(pubKey.x.toBytes().length, equals(32));
      expect(pubKey.y.toBytes().length, equals(32));

      final absPubKey = privateKeyBytesToPublic(hexToBytes(validPrivateKey));
      final concat = pubKey.x.toBytes().concat(pubKey.y.toBytes());
      expect(concat.length, equals(64));
      expect(concat, equals(absPubKey));
    });

    test('signs personal message (EIP-191)', () async {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final message = utf8.encode("Hello World");
      final signature = await signer.personalSign(message);

      // Verify recovery (Eip1271Verifier check)
      final isValid = Eip1271Verifier.isValidSignedMessage(
        message,
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });

    test('signs a payload async', () async {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );

      final signature = await signer.signAsync(Bytes(32));

      expect(signature, isNotNull);
      expect(signature.curve, equals(SigningCurve.k1));

      final isValid = Eip1271Verifier.isValidECSignature(
        Bytes(32),
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });

    test('signs a payload sync', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );

      final signature = signer.sign(Bytes(32));

      expect(signature, isNotNull);
      expect(signature.curve, equals(SigningCurve.k1));

      final isValid = Eip1271Verifier.isValidECSignature(
        Bytes(32),
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });

    test('signs typed data (EIP-712)', () async {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final signature = await signer.signTypedData(
        rawTypedData,
        TypedDataVersion.v4,
      );

      // Verify recovery
      final isValid = Eip1271Verifier.isValidSignedTypedData(
        rawTypedData,
        TypedDataVersion.v4,
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(ERC1271IsValidSignatureResponse.success));
    });

    test('supports sync signing', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      expect(signer.supportsSyncSigning, isTrue);
    });

    test('does not support user presence/verification', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      expect(signer.supportsUserPresence, isFalse);
      expect(signer.supportsUserVerification, isFalse);
    });

    test('signer can be recovered cross device', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      expect(signer.isRecoverable, isTrue);
    });

    test('getDummySignature returns valid placeholder', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final dummy = signer.getDummySignature();
      // Valid dummy signature should look like a signature
      expect(dummy.r, isNotNull);
      expect(dummy.s, isNotNull);
    });
  });
}

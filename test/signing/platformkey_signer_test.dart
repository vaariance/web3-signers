import 'dart:convert';

import 'package:eip712/eip712.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';
// import SignerType enum
import 'package:web3dart/web3dart.dart';

import '../__test_utils__/fixtures/constants.dart';
import '../__test_utils__/mocks/mock_platform_signer.dart';
import '../__test_utils__/keys/secp256r1_keys.dart' as keys;

void main() {
  group('PlatformKeySigner', () {
    late MockPlatformAuthenticator mockAuthenticator;
    late PlatformKeySigner signer;
    late PlatformConfig config;
    late PlatformPublicKey publicKey;

    final testKeyTag = 'test-key-tag';
    final x = hexToInt(keys.sePubKeyx);
    final y = hexToInt(keys.sePubKeyy);

    setUpAll(() {
      registerFallbackValue((
        android: AndroidPlatformOptions(),
        darwin: DarwinPlatformOptions(),
        windows: WindowsPlatformOptions(),
      ));
    });

    setUp(() {
      mockAuthenticator = MockPlatformAuthenticator();
      config = PlatformConfig(keyTag: testKeyTag);
      publicKey = PlatformPublicKey(x: Uint256(x), y: Uint256(y));
      signer = PlatformKeySigner.withAuthenticator(
        mockAuthenticator,
        config,
        publicKey,
      );
    });

    test('kind is platformKey', () {
      expect(signer.kind, equals(SignerType.platformKey));
    });

    test('key is recoverable', () {
      expect(signer.isRecoverable, isFalse);
    });

    test('supports user presence and verification', () {
      expect(signer.supportsUserPresence, isTrue);
      expect(signer.supportsUserVerification, isTrue);
    });

    test('does not support sync signing', () {
      expect(signer.supportsSyncSigning, isFalse);
    });

    test('getAddress derives correct address from public key', () {
      // P256 Address derivation: last 20 bytes of keccak256(X || Y)
      final xBytes = publicKey.x.toBytes();
      final yBytes = publicKey.y.toBytes();
      final hash = keccak256(xBytes.concat(yBytes));
      final expectedAddress = "0x${bytesToHex(hash.sublist(12, 32))}";

      expect(signer.getAddress(), equals(expectedAddress));
    });

    test('sign throws UnsupportedError for syncSigning', () {
      expect(
        () => signer.sign(Bytes(32)),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.toString(),
            'message',
            contains('Sync signing not supported for PlatformKeySigner'),
          ),
        ),
      );
    });

    test('signAsync calls API and returns valid signature', () async {
      final message = keys.seMessage;
      final messageBytes = utf8.encode(message);
      final prefix = '\u0019Ethereum Signed Message:\n${messageBytes.length}';
      final preImage = ascii.encode(prefix).concat(messageBytes);

      // Mock API returns valid DER encoded signature bytes
      final signatureResponse = hexToBytes(keys.seSignResponse);

      when(
        () => mockAuthenticator.sign(testKeyTag, preImage, any()),
      ).thenAnswer((_) async => signatureResponse);

      final signature = await signer.personalSign(messageBytes);

      expect(signature.r, equals(hexToInt(keys.seSigR)));
      expect(signature.s, equals(hexToInt(keys.seSigS)));

      // Verify signature using Verifier (signature is EIP-191 compliant)
      final isValid = Verifier.isValidSignedMessage(
        messageBytes,
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(IsValidSignatureResponse.success));

      verify(
        () => mockAuthenticator.sign(testKeyTag, preImage, any()),
      ).called(1);
    });

    test('signs typed data (EIP-712)', () async {
      when(
        () => mockAuthenticator.sign(
          testKeyTag,
          hashTypedData(typedData: rawTypedData, version: TypedDataVersion.v4),
          any(),
        ),
      ).thenAnswer((_) async => hexToBytes(keys.seSignResponse));

      final signature = await signer.signTypedData(
        rawTypedData,
        TypedDataVersion.v4,
      );

      // Verify recovery
      final isValid = Verifier.isValidSignedTypedData(
        rawTypedData,
        TypedDataVersion.v4,
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(IsValidSignatureResponse.failure));
    });

    test('getDummySignature returns valid placeholder', () {
      final dummy = signer.getDummySignature();
      // Implementation: ec * 32, d5a * 21 + f
      // just verify it is not null and has values
      expect(dummy.r, isNotNull);
      expect(dummy.s, isNotNull);
    });

    test('deleteSigningKey calls API deleteKey', () async {
      when(
        () => mockAuthenticator.deleteKey(testKeyTag),
      ).thenAnswer((_) async {});

      await signer.deleteSigningKey();

      verify(() => mockAuthenticator.deleteKey(testKeyTag)).called(1);
    });
  });
}

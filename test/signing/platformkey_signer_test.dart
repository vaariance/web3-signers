import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';
// import SignerType enum
import 'package:web3dart/web3dart.dart';

import '../__test_utils__/mocks/mock_platform_signer.dart';

void main() {
  group('PlatformKeySigner', () {
    late MockPlatformAuthenticator mockAuthenticator;
    late PlatformKeySigner signer;
    late PlatformConfig config;
    late PlatformPublicKey publicKey;

    final testKeyTag = 'test-key-tag';
    final x = BigInt.parse(
      "1234567890123456789012345678901234567890123456789012345678901234",
    );
    final y = BigInt.parse(
      "1234567890123456789012345678901234567890123456789012345678901234",
    );

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

    // TODO: use a valid ASN.1 signature
    // test('signAsync calls API and returns valid signature', () async {
    //   final message = utf8.encode("Hello World");

    //   // Mock API returns r and s bytes
    //   // Expected signature bytes (64 bytes: 32 R + 32 S)
    //   final rBytes = List.filled(32, 1);
    //   final sBytes = List.filled(32, 2);
    //   final signatureBytes = [...rBytes, ...sBytes];

    //   when(
    //     () => mockApi.sign(testKeyTag, any()),
    //   ).thenAnswer((_) async => signatureBytes);

    //   final signature = await signer.signAsync(message);

    //   expect(
    //     signature.r,
    //     equals(
    //       BigInt.parse(
    //         "0101010101010101010101010101010101010101010101010101010101010101",
    //         radix: 16,
    //       ),
    //     ),
    //   );
    //   expect(
    //     signature.s,
    //     equals(
    //       BigInt.parse(
    //         "0202020202020202020202020202020202020202020202020202020202020202",
    //         radix: 16,
    //       ),
    //     ),
    //   );

    //   verify(() => mockApi.sign(testKeyTag, message)).called(1);
    // });

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

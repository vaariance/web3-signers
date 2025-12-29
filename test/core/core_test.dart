import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:passkeys/types.dart';

import '../__test_utils__/keys/secp256r1_keys.dart';
import '../__test_utils__/mocks/mock_platform_signer.dart';
import '../__test_utils__/mocks/mock_authenticator.dart';

void main() {
  group('Core', () {
    test('generatePrivateKey returns 32 bytes', () {
      final key = generatePrivateKey();
      expect(key.length, equals(32));
    });

    group('generatePlatformKey', () {
      late MockPlatformAuthenticator mockAuthenticator;
      late PlatformConfig config;

      setUp(() {
        mockAuthenticator = MockPlatformAuthenticator();
        config = PlatformConfig(keyTag: 'test-tag');
      });

      test('creates new key if checkExisting is false (default)', () async {
        final pubKeyBytes = Bytes.fromList([
          0x04,
          ...List.filled(32, 1),
          ...List.filled(32, 2),
        ]);
        when(
          () => mockAuthenticator.createKey('test-tag'),
        ).thenAnswer((_) async => pubKeyBytes);

        final key = await generatePlatformKey(
          config: config,
          auth: mockAuthenticator,
        );

        verify(() => mockAuthenticator.createKey('test-tag')).called(1);
        verifyNever(() => mockAuthenticator.getPublicKey(any()));

        expect(key.x.toBytes(), equals(List.filled(32, 1)));
        expect(key.y.toBytes(), equals(List.filled(32, 2)));
      });

      test('gets existing key if checkExisting is true', () async {
        final pubKeyBytes = Bytes.fromList([
          0x04,
          ...List.filled(32, 3),
          ...List.filled(32, 4),
        ]);
        when(
          () => mockAuthenticator.getPublicKey('test-tag'),
        ).thenAnswer((_) async => pubKeyBytes);

        final key = await generatePlatformKey(
          config: config,
          checkExisting: true,
          auth: mockAuthenticator,
        );

        verify(() => mockAuthenticator.getPublicKey('test-tag')).called(1);
        verifyNever(() => mockAuthenticator.createKey(any()));

        expect(key.x.toBytes(), equals(List.filled(32, 3)));
        expect(key.y.toBytes(), equals(List.filled(32, 4)));
      });

      test(
        'creates key if getPublicKey returns null even with checkExisting',
        () async {
          final pubKeyBytes = Bytes.fromList([
            0x04,
            ...List.filled(32, 5),
            ...List.filled(32, 6),
          ]);
          when(
            () => mockAuthenticator.getPublicKey('test-tag'),
          ).thenAnswer((_) async => null);
          when(
            () => mockAuthenticator.createKey('test-tag'),
          ).thenAnswer((_) async => pubKeyBytes);

          await generatePlatformKey(
            config: config,
            checkExisting: true,
            auth: mockAuthenticator,
          );

          verify(() => mockAuthenticator.getPublicKey('test-tag')).called(1);
          verify(() => mockAuthenticator.createKey('test-tag')).called(1);
        },
      );
    });

    group("Generate PassKey", () {
      late MockPasskeyAuthenticator mockAuth;

      setUp(() {
        mockAuth = MockPasskeyAuthenticator();
        registerFallbackValue(FakeRegisterRequestType());
      });

      test("generatePassKey returns a valid PassKeyPublicKey", () async {
        final config = PassKeyConfig(
          rpId: 'user@variance.space',
          rpName: 'test user',
        );

        final registerResponse = RegisterResponseType(
          id: credentialId,
          rawId: credentialId,
          clientDataJSON: testRegisterResponse.first,
          attestationObject: testRegisterResponse.last,
          transports: [],
        );

        when(
          () => mockAuth.register(any()),
        ).thenAnswer((_) async => registerResponse);

        final result = await generatePassKey(
          config: config,
          username: "testuser",
          displayname: "Test User",
          auth: mockAuth,
        );

        expect(result, isA<PassKeyPublicKey>());
        expect(result.userName, equals("testuser"));
        expect(result.credentialId, b64d(credentialId));
        // Verify X and Y were parsed correctly (attestation object contains specific key)
        expect(result.x.toBytes().isNotEmpty, isTrue);
        expect(result.y.toBytes().isNotEmpty, isTrue);
      });
    });
  });
}

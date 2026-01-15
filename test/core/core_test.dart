import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';
import 'package:passkeys/types.dart';

import '../__test_utils__/keys/secp256r1_keys.dart' as keys;
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

      setUpAll(() {
        registerFallbackValue((
          android: AndroidPlatformOptions(),
          darwin: DarwinPlatformOptions(),
          windows: WindowsPlatformOptions(),
        ));
      });

      setUp(() {
        mockAuthenticator = MockPlatformAuthenticator();
        config = PlatformConfig(keyTag: 'test-tag');
      });

      test('creates new key if checkExisting is false (default)', () async {
        final pubKeyBytes = hexToBytes(keys.seCreateRes);
        when(
          () => mockAuthenticator.createKey('test-tag', any()),
        ).thenAnswer((_) async => pubKeyBytes);

        final key = await generatePlatformKey(
          config: config,
          auth: mockAuthenticator,
        );

        verify(() => mockAuthenticator.createKey('test-tag', any())).called(1);
        verifyNever(() => mockAuthenticator.getPublicKey(any()));

        expect(key.x.toHex(), equals(keys.sePubKeyx));
        expect(key.y.toHex(), equals(keys.sePubKeyy));
      });

      test('gets existing key if checkExisting is true', () async {
        final pubKeyBytes = hexToBytes(keys.seCreateRes);
        when(
          () => mockAuthenticator.getPublicKey('test-tag'),
        ).thenAnswer((_) async => pubKeyBytes);

        final key = await generatePlatformKey(
          config: config,
          checkExisting: true,
          auth: mockAuthenticator,
        );

        verify(() => mockAuthenticator.getPublicKey('test-tag')).called(1);
        verifyNever(() => mockAuthenticator.createKey(any(), any()));

        expect(key.x.toHex(), equals(keys.sePubKeyx));
        expect(key.y.toHex(), equals(keys.sePubKeyy));
      });

      test(
        'creates key if getPublicKey returns null even with checkExisting',
        () async {
          final pubKeyBytes = hexToBytes(keys.seCreateRes);
          when(
            () => mockAuthenticator.getPublicKey('test-tag'),
          ).thenAnswer((_) async => null);
          when(
            () => mockAuthenticator.createKey('test-tag', any()),
          ).thenAnswer((_) async => pubKeyBytes);

          await generatePlatformKey(
            config: config,
            checkExisting: true,
            auth: mockAuthenticator,
          );

          verify(() => mockAuthenticator.getPublicKey('test-tag')).called(1);
          verify(
            () => mockAuthenticator.createKey('test-tag', any()),
          ).called(1);
        },
      );

      test("throws exception if publick key is invlaid", () {
        final pubKeyBytes = hexToBytes(keys.seCreateRes);
        when(
          () => mockAuthenticator.createKey('test-tag', any()),
        ).thenAnswer((_) async => pubKeyBytes.sublist(1));

        expect(
          () => generatePlatformKey(config: config, auth: mockAuthenticator),
          throwsA(
            isA<FormatException>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid public key format from platform'),
            ),
          ),
        );
      });
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
          id: keys.credentialId,
          rawId: keys.credentialId,
          clientDataJSON: keys.testRegisterResponse.first,
          attestationObject: keys.testRegisterResponse.last,
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
        expect(result.credentialId, b64d(keys.credentialId));
        // Verify X and Y were parsed correctly (attestation object contains specific key)
        expect(result.x.toBytes().isNotEmpty, isTrue);
        expect(result.y.toBytes().isNotEmpty, isTrue);

        when(
          () => mockAuth.register(any()),
        ).thenAnswer((_) async => registerResponse);

        final resultWithExcludedCredential = await generatePassKey(
          config: config,
          username: "testuser",
          displayname: "Test User",
          auth: mockAuth,
          excludedCredentials: [b64d("0ohsLBsE-Xs-QvGnLSWFe5Zx19Y")],
        );

        expect(resultWithExcludedCredential, isA<PassKeyPublicKey>());
      });
    });
  });
}

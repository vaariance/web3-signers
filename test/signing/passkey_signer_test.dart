import 'dart:convert';
import 'package:eip712/eip712.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:passkeys/types.dart';
import 'package:web3dart/web3dart.dart';

import '../__test_utils__/fixtures/constants.dart';
import '../__test_utils__/keys/secp256r1_keys.dart';
import '../__test_utils__/mocks/mock_authenticator.dart';

void main() {
  group('PassKeySigner', () {
    late MockPasskeyAuthenticator mockAuthenticator;
    late PassKeySigner signer;
    late PassKeyConfig config;

    setUpAll(() {
      registerFallbackValue(FakeAuthenticateRequestType());
    });

    setUp(() {
      mockAuthenticator = MockPasskeyAuthenticator();
      config = PassKeyConfig(rpId: "variance.space", rpName: "Variance");
      signer = PassKeySigner.withAuthenticator(
        mockAuthenticator,
        config,
        testP256PublicKey,
      );
    });

    tearDown(() {
      reset(mockAuthenticator);
    });

    test('signer kind is passKey', () {
      expect(signer.kind, equals(SignerType.passKey));
    });

    test('supports user presence and verification', () {
      expect(signer.supportsUserPresence, isTrue);
      expect(signer.supportsUserVerification, isTrue);
    });

    test('returns a valid public key for the signer', () {
      final pubKey = signer.publicKey;
      expect(pubKey.x.toBytes().length, equals(32));
      expect(pubKey.y.toBytes().length, equals(32));

      expect(pubKey.x, equals(testP256PublicKey.x));
      expect(pubKey.y, equals(testP256PublicKey.y));
      expect(pubKey.credentialId, equals(b64d(credentialId)));
      expect(pubKey.userName, equals("Test User"));
    });

    test('getAddress derives correct address from public key', () {
      final x = testP256PublicKey.x.toBytes();
      final y = testP256PublicKey.y.toBytes();
      final hash = keccak256(x.concat(y));
      final expectedAddress = "0x${bytesToHex(hash.sublist(12, 32))}";

      expect(signer.getAddress(), equals(expectedAddress));
    });

    test(
      'signAsync calls authenticator and returns valid signature from mock data',
      () async {
        final message = Bytes(32);

        when(() => mockAuthenticator.authenticate(any())).thenAnswer((_) async {
          return AuthenticateResponseType(
            id: credentialId,
            rawId: credentialId,
            authenticatorData: validAuthenticatorData,
            clientDataJSON: validClientDataJSON,
            signature: validSignature,
            userHandle: validUserHandle,
          );
        });

        final signature = await signer.signAsync(message);

        // Verify the signature components against the expected values derived from validSignature
        final expectedParsed = getMessagingSignature(b64d(validSignature));
        expect(signature.r, equals(expectedParsed.r.value));
        expect(signature.s, equals(expectedParsed.s.value));
        expect(signature.authData, equals(b64d(validAuthenticatorData)));
        expect(
          signature.clientDataJson,
          equals(utf8.decode(b64d(validClientDataJSON))),
        );
        expect(signature.curve, equals(SigningCurve.r1));

        // Verify authenticate was called with correct challenge
        verify(() => mockAuthenticator.authenticate(any())).called(1);

        final isValid = Verifier.isValidECSignature(
          message,
          signature,
          signer.publicKey,
        );
        expect(isValid, equals(IsValidSignatureResponse.success));
      },
    );

    test('signs personal message (EIP-191)', () async {
      final message = utf8.encode("Hello World");

      when(() => mockAuthenticator.authenticate(any())).thenAnswer((_) async {
        return AuthenticateResponseType(
          id: credentialId,
          rawId: credentialId,
          authenticatorData: validAuthenticatorData,
          clientDataJSON: validClientDataJSON,
          signature: validSignature,
          userHandle: validUserHandle,
        );
      });

      final signature = await signer.personalSign(message);
      // Verify recovery (Verifier check)
      final isValid = Verifier.isValidSignedMessage(
        message,
        signature,
        signer.publicKey,
      );
      expect(isValid, equals(IsValidSignatureResponse.failure));
    });

    test('signs typed data (EIP-712)', () async {
      when(() => mockAuthenticator.authenticate(any())).thenAnswer((_) async {
        return AuthenticateResponseType(
          id: credentialId,
          rawId: credentialId,
          authenticatorData: validAuthenticatorData,
          clientDataJSON: validClientDataJSON,
          signature: validSignature,
          userHandle: validUserHandle,
        );
      });
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

    test('get challenge and type positions from signature', () async {
      final message = Bytes(32);

      when(() => mockAuthenticator.authenticate(any())).thenAnswer((_) async {
        return AuthenticateResponseType(
          id: credentialId,
          rawId: credentialId,
          authenticatorData: validAuthenticatorData,
          clientDataJSON: validClientDataJSON,
          signature: validSignature,
          userHandle: validUserHandle,
        );
      });

      final signature = await signer.signAsync(message);
      final challengePos = signature.getChallengeLocation(message);
      expect(challengePos, isNotNull);
      final typePos = signature.getTypeLocation();
      expect(typePos, isNotNull);
      final type = signature.clientDataJson!.substring(typePos!);
      expect(type, startsWith('"type"'));
      final challenge = signature.clientDataJson!.substring(
        challengePos!,
        challengePos + b64e(message).length,
      );
      expect(challenge, equals(b64e(message)));
    });

    test('does not support sync signing', () {
      expect(signer.supportsSyncSigning, isFalse);
      expect(() => signer.sign(Bytes(32)), throwsUnsupportedError);
    });

    test('signer can be recovered cross device', () {
      expect(signer.isRecoverable, isTrue);
    });

    test('getDummySignature returns valid placeholder', () {
      final dummy = signer.getDummySignature();
      expect(dummy.r, isNotNull);
      expect(dummy.s, isNotNull);
    });
  });
}

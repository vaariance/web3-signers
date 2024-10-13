import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passkeys/types.dart';
import 'package:web3_signers/src/interfaces/interfaces.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'dart:typed_data';

@GenerateNiceMocks([MockSpec<Authenticator>()])
import 'passkey_signer_test.mocks.dart';

void main() {
  group('PassKeySigner Tests', () {
    late PassKeySigner passKeySigner;
    late MockAuthenticator mockAuthenticator;
    late HttpClient httpClient;

    final options = PassKeysOptions(
        namespace: 'variance.space',
        name: 'Variance',
        origin: 'https://variance.space',
        requireResidentKey: true,
        userVerification: "required",
        sharedWebauthnSigner: EthereumAddress.fromHex(
            "0xfD90FAd33ee8b58f32c00aceEad1358e4AFC23f9"));

    final credentialTestId = "xLY8if5aHhPNSToeYXXOpA";
    final testpkX =
        "0xedf717baff9a87fd4b031a2a066580a9a29bdba97e2fd55820f7cd5c963f09ae";
    final testpkY =
        "0x276c0acd7ed3c8ad8db88f0c15f5d19b12aaa2af3f26c9003e07afd95b980fe5";
    final cdjRgExp = RegExp(
        r'^\{"type":"webauthn.get","challenge":"[A-Za-z0-9\-_]{43}",(.*)\}$');
    final String p256VerifierAddress =
        '0xc2b78104907F722DABAc4C69f826a522B2754De4';
    final String rpcUrl = 'https://rpc.ankr.com/base';

    setUp(() {
      // Initialize the mock authenticator
      mockAuthenticator = MockAuthenticator();

      // Inject the mock authenticator into the PassKeySigner
      passKeySigner = PassKeySigner(options: options, auth: mockAuthenticator);

      httpClient = HttpClient();
    });

    tearDown(() {
      httpClient.close();
    });

    Future verify(Uint8List calldata) async {
      final String requestBody = json.encode({
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': p256VerifierAddress,
            'data': hexlify(calldata),
          },
          'latest'
        ],
        'id': 1
      });

      final Uri uri = Uri.parse(rpcUrl);
      final HttpClientRequest request = await httpClient.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(requestBody));

      final HttpClientResponse response = await request.close();
      final String responseBody = await response.transform(utf8.decoder).join();

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (jsonResponse.containsKey('error')) {
        return Uint256.zero;
      } else if (jsonResponse.containsKey('result')) {
        return Uint256.fromHex(jsonResponse['result']);
      } else {
        return Uint256.zero;
      }
    }

    test('Initialization of PassKeySigner', () {
      expect(passKeySigner.opts.namespace, equals('variance.space'));
      expect(passKeySigner.opts.name, equals('Variance'));
      expect(passKeySigner.opts.origin, equals('https://variance.space'));
      expect(passKeySigner.credentialIds, isEmpty);
    });

    test('Random Base64 String Generation', () {
      final randomString = passKeySigner.randomBase64String();
      expect(randomString, isA<String>());
      // Base64 URL-safe encoding without padding
      expect(RegExp(r'^[A-Za-z0-9\-_]{43}$').hasMatch(randomString), isTrue);
    });

    test('Get Dummy Signature', () {
      final dummySignature = passKeySigner.getDummySignature();
      expect(dummySignature, isA<String>());
      // The dummy signature should be a hex string
      expect(dummySignature.startsWith('0x'), isTrue);
      expect(dummySignature.length, greaterThan(193));

      final decode = abi.decode(['bytes', 'bytes', 'uint256[2]'],
          hexToBytes(dummySignature.substring(196)));
      final authData = decode[0];
      final clientDataJSON = utf8.decode(decode[1]);

      final dummyCdField =
          '{"type":"webauthn.get","challenge":"p5aV2uHXr0AOqUk7HQitvi-Ny1p5aV2uHXr0AOqUk7H","origin":"android:apk-key-hash:5--XhhrpNeH_K2aYpxYxOupzRZZkBz1dGUTuwDUaDNI","androidPackageName":"com.example.web3_signers"}';
      final dummyAdField = Uint8List(37);
      dummyAdField.fillRange(0, dummyAdField.length, 0xfe);
      dummyAdField[32] = 0x04;
      final match = cdjRgExp.firstMatch(dummyCdField)!;

      expect(clientDataJSON, equals(match[1]));
      expect(authData, equals(dummyAdField));
    });

    test('Get Address with no credentials', () {
      expect(() => passKeySigner.getAddress(), throwsA(isA<Error>()));
    });

    test('Get Address with credentials', () {
      final credentialId = getRandomValues();
      passKeySigner.credentialIds.add(credentialId);
      final address = passKeySigner.getAddress();
      expect(address, equals(base64Url.encode(credentialId)));
    });

    test('Sign with mocked authenticate', () async {
      final hash = Uint8List(32);

      final authenticateResponse = AuthenticateResponseType(
          authenticatorData:
              "TjGXzAiZUHkjJiaVfkQODGrY7iI99BhKRPZA4cYXaW0dAAAAAA",
          signature:
              "MEQCIB0xbkk_A9dhf63DMqVIkYevEVYi0-HmSMGrcmkvahCrAiBnC0WhB1Hm0Wulzwudf1w8KpAXbtOjz8Qbl9vO3xYZHw",
          id: credentialTestId,
          rawId: credentialTestId,
          clientDataJSON:
              "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQSIsIm9yaWdpbiI6ImFuZHJvaWQ6YXBrLWtleS1oYXNoOjUtLVhoaHJwTmVIX0syYVlweFl4T3VwelJaWmtCejFkR1VUdXdEVWFETkkiLCJhbmRyb2lkUGFja2FnZU5hbWUiOiJjb20uZXhhbXBsZS53ZWIzX3NpZ25lcnMifQ",
          userHandle: "2on6z7AARXOKnB8-U-Mtyw");

      when(mockAuthenticator.authenticate(any))
          .thenAnswer((_) async => authenticateResponse);

      // Add a known credential
      passKeySigner.credentialIds.add(b64d(credentialTestId));

      final signature = await passKeySigner.signToPasskeySignature(hash);

      expect(signature, isA<PassKeySignature>());

      final hashBase64 = b64e(hash);
      final clientDataJSON =
          '{"type":"webauthn.get","challenge":"$hashBase64",${cdjRgExp.firstMatch(signature.clientDataJSON)![1]}}';
      final clientHash = sha256Hash(utf8.encode(clientDataJSON));
      final sigHash =
          sha256Hash(signature.authData.concat(Uint8List.fromList(clientHash)));
      final calldata = abi.encode([
        "uint256",
        "uint256",
        "uint256",
        "uint256",
        "uint256"
      ], [
        bytesToInt(sigHash),
        signature.signature.item1.value,
        signature.signature.item2.value,
        hexToInt(testpkX),
        hexToInt(testpkY)
      ]);
      final valid = await verify(calldata);

      expect(valid.value, equals(BigInt.one));
    });

    test('Register with mocked register method', () async {
      // Prepare mock responses
      final registerResponse = RegisterResponseType(
        id: credentialTestId,
        rawId: credentialTestId,
        clientDataJSON:
            "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiYnVITHpGLTk0XzBCZENMcklpOThMNDBLUlNfNl9HSlhMM0tsTC04M3hkayIsIm9yaWdpbiI6ImFuZHJvaWQ6YXBrLWtleS1oYXNoOjUtLVhoaHJwTmVIX0syYVlweFl4T3VwelJaWmtCejFkR1VUdXdEVWFETkkiLCJhbmRyb2lkUGFja2FnZU5hbWUiOiJjb20uZXhhbXBsZS53ZWIzX3NpZ25lcnMifQ",
        attestationObject:
            "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YViUTjGXzAiZUHkjJiaVfkQODGrY7iI99BhKRPZA4cYXaW1dAAAAAOqbjWZNAR0hPOS2tIy1ddQAEMS2PIn-Wh4TzUk6HmF1zqSlAQIDJiABIVgg7fcXuv-ah_1LAxoqBmWAqaKb26l-L9VYIPfNXJY_Ca4iWCAnbArNftPIrY24jwwV9dGbEqqirz8myQA-B6_ZW5gP5Q",
      );

      when(mockAuthenticator.register(any))
          .thenAnswer((_) async => registerResponse);

      final passKeyPair =
          await passKeySigner.register("user@variance.space", "test user");

      expect(passKeyPair, isA<PassKeyPair>());
      expect(passKeyPair.authData, isA<AuthData>());
      expect(passKeyPair.authData.publicKey.item1.toHex(), equals(testpkX));
      expect(passKeyPair.authData.publicKey.item2.toHex(), equals(testpkY));
    });
  });
}

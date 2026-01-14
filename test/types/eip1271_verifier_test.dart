import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/src/utils/constants.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes;

import '../__test_utils__/keys/secp256k1_keys.dart';
import '../__test_utils__/mocks/mock_rpc_handler.dart';

void main() {
  group('Verifier', () {
    test('isValidECSignature verifies valid signatures', () {
      final signer = LocalKeySigner.fromRawPrivateKey(
        hexToBytes(validPrivateKey),
      );
      final message = Bytes.fromList(List.filled(32, 0x1));

      // Manually sign (we know LocalKeySigner does correct signature)
      final signature = signer.sign(
        message,
      ); // signs without prefix if we call sign() directly?
      // LocalKeySigner.sign calls _ethPrivateKey.signToEcSignature with EIP1559=true?
      // Actually sign() just signs the hash.

      final isValid = Verifier.isValidECSignature(
        message,
        signature,
        signer.publicKey,
      );

      expect(isValid, equals(IsValidSignatureResponse.success));
    });

    test('isValidContractSignature returns success on magic value', () async {
      final rpcUrl = "http://localhost:8545";

      HttpOverrides.runZoned(
        () async {
          final isValid = await Verifier.isValidContractSignature(
            Bytes(32),
            Bytes(65),
            defaultP256Verifier,
            rpcUrl,
          );
          expect(isValid, equals(IsValidSignatureResponse.success));
        },
        createHttpClient: (context) {
          return MockRpcHandler((requestBody) {
            // Check request if needed
            return {"jsonrpc": "2.0", "id": 1, "result": "0x1626ba7e"};
          }).createHttpClient(context);
        },
      );
    });
  });
}

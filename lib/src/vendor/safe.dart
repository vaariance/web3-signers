// coverage:ignore-file
import 'dart:convert';

import 'package:eip7702/eip7702.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

final RegExp cdjRegex = RegExp(
  r'^\{"type":"webauthn.get","challenge":"[A-Za-z0-9\-_]{43}",(.*)\}$',
);

Bytes buildSafePassKeySignatureBytes(
  HexString sharedSigner,
  Signature signature,
) {
  final data = safePassKeySignatureToBytes(signature);
  final signerBytes = toEthAddress(sharedSigner).value.padLeft();
  final dynamicPartPosition = intToBytes(BigInt.from(65)).padLeft();
  final dynamicPartLength = intToBytes(BigInt.from((data.length))).padLeft();
  final staticSignature = signerBytes
      .concat(dynamicPartPosition)
      .concat(Bytes(1));

  return staticSignature.concat(dynamicPartLength).concat(data);
}

Bytes safePassKeySignatureToBytes(Signature signature) {
  final match = cdjRegex.firstMatch(signature.clientDataJson!)!;
  return Abi.encode(
    ['bytes', 'bytes', 'uint256[2]'],
    [
      signature.authData,
      utf8.encode(match[1]!),
      [signature.r, signature.s],
    ],
  );
}

part of '../../web3_signers.dart';

/// Derives the BIP-32 master key and chain code from seed.
///
/// - Uses HMAC-SHA512 with key `"Bitcoin seed"`.
/// - Left 32 bytes: master private key; right 32 bytes: chain code.
({Bytes key, Bytes chain}) _deriveMaster(Bytes seed) {
  final hmac = HMac(SHA512Digest(), 128);
  hmac.init(KeyParameter(utf8.encode("Bitcoin seed")));
  final master = hmac.process(seed);
  return (key: master.sublist(0, 32), chain: master.sublist(32, 64));
}

/// Parses a BIP-32 derivation path into integer indices.
///
/// - Removes the leading `m/` if present.
/// - Appends `0x80000000` to hardened indices (those ending in `'`).
///
/// Returns:
/// - List of 32-bit indices suitable for child key derivation.
List<int> _parseDerivationPath(String path) {
  var p = path;
  if (p.startsWith('m/')) p = p.substring(2);

  return p.split('/').map((segment) {
    final isHardened = segment.endsWith("'");
    final indexStr =
        isHardened ? segment.substring(0, segment.length - 1) : segment;
    final index = int.parse(indexStr);
    return isHardened ? index + 0x80000000 : index;
  }).toList();
}

/// Derives a child key given parent private key and chain code.
///
/// - Hardened: prepend `0x00` and parent key to the data block.
/// - Non-hardened: use the compressed public key of the parent.
/// - Returns child private key and next chain code.
({Bytes key, Bytes chain}) _deriveChild(
  Bytes parentKey,
  Bytes parentChain,
  int index,
) {
  final hmac = HMac(SHA512Digest(), 128);
  hmac.init(KeyParameter(parentChain));

  final domain = ECCurve_secp256k1();
  final data = Bytes(37);
  final dataView = ByteData.view(data.buffer);

  if (index >= 0x80000000) {
    data[0] = 0x00;
    data.setRange(1, 33, parentKey);
  } else {
    // Parent Key is 32 bytes BigInt, we need to convert to Point -> Compressed Bytes
    final pKeyBigInt = BigInt.parse(bytesToHex(parentKey), radix: 16);
    final q = domain.G * pKeyBigInt;
    data.setRange(0, 33, q!.getEncoded(true));
  }
  dataView.setUint32(33, index, Endian.big);

  final i = hmac.process(data);
  final il = i.sublist(0, 32);
  final ir = i.sublist(32, 64);

  final kb = _calculateChildKey(il, parentKey, domain);

  return (key: kb, chain: ir);
}

/// Computes the child private key: `(IL + parentKey) mod n`.
Bytes _calculateChildKey(Bytes il, Bytes parentKey, ECCurve_secp256k1 domain) {
  final ilInt = BigInt.parse(bytesToHex(il), radix: 16);
  final pKeyInt = BigInt.parse(bytesToHex(parentKey), radix: 16);
  final ki = (ilInt + pKeyInt) % domain.n;

  var kh = ki.toRadixString(16);
  if (kh.length % 2 != 0) kh = '0$kh';
  final kb = Bytes(32);

  final src = Bytes.fromList(
    List<int>.generate(
      kh.length ~/ 2,
      (x) => int.parse(kh.substring(x * 2, x * 2 + 2), radix: 16),
    ),
  );
  kb.setRange(32 - src.length, 32, src);

  return kb;
}

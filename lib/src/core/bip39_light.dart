part of '../../web3_signers.dart';

/// Generates a random BIP-39 mnemonic in English.
///
/// - `wordLength` controls target entropy and checksum size.
/// - Note: Current implementation uses 32 bytes of entropy; it is optimized
///   for 24-word mnemonics. Other lengths may not match the intended entropy
///   distribution without further adjustments.
///
/// Parameters:
/// - [wordLength]: Desired word count preset.
///
/// Returns:
/// - Mnemonic string of space-separated words.
String generateMnemonic([WordLength wordLength = WordLength.word_24]) {
  final strength = wordLength.wordsStrength;
  final bitsBuffer = StringBuffer();

  final entropy = getRandomValues();
  final entropyBits = entropy.map((e) => e.toRadixString(2).padLeft(8, '0'));
  final hash = sha256Hash(entropy);
  final hashBits = hash.map((e) => e.toRadixString(2).padLeft(8, '0'));

  bitsBuffer.write(entropyBits.join(''));
  bitsBuffer.write(hashBits.join('').substring(0, strength ~/ 32));

  final bits = bitsBuffer.toString();

  final words = <String>[];
  for (int i = 0; i < bits.length; i += 11) {
    final indexBits = bits.substring(i, i + 11);
    final index = int.parse(indexBits, radix: 2);
    words.add(_bip39EnglishWords[index]);
  }

  return words.join(' ');
}

/// Converts a BIP-39 mnemonic to a seed using PBKDF2-HMAC-SHA512.
///
/// - Salt: the ASCII string `"mnemonic"`.
/// - Iterations: `2048`.
/// - Output length: `64` bytes.
Bytes _mnemonicToSeed(String mnemonic) {
  final salt = utf8.encode("mnemonic");
  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128))
    ..init(Pbkdf2Parameters(Bytes.fromList(salt), 2048, 64));
  return pbkdf2.process(Bytes.fromList(utf8.encode(mnemonic)));
}

part of 'vendor.dart';

const _defaultLength = 32;

/// Generates a Uint8List of random values.
///
/// Parameters:
/// - [length]: The length of the random byte array to generate. Defaults to [_defaultLength].
///
/// Returns a Uint8List of random bytes.
///
/// Example:
/// ```dart
/// final randomBytes = getRandomValues(16);
/// print(randomBytes.length); // Prints: 16
/// ```
Uint8List getRandomValues([int length = _defaultLength]) {
  final DartRandom rn = DartRandom(Random.secure());
  String entropy = rn.nextBigInteger(length * 8).toRadixString(16);

  if (entropy.length > length * 2) {
    entropy = entropy.substring(0, length * 2);
  }

  String randomPers = rn.nextBigInteger(length * 8).toRadixString(16);

  if (randomPers.length > length * 2) {
    randomPers = randomPers.substring(0, length * 2);
  }
  return hexToBytes(randomPers);
}

/// Generates a Uint8List of random values.
///
/// This function is an alias for [getRandomValues].
///
/// Parameters:
/// - [length]: The length of the random byte array to generate. Defaults to [_defaultLength].
///
/// Returns a Uint8List of random bytes.
///
/// Example:
/// ```dart
/// final randomBytes = randomAsU8a(16);
/// print(randomBytes.length); // Prints: 16
/// ```
Uint8List randomAsU8a([int length = _defaultLength]) {
  return getRandomValues(length);
}

class DartRandom {
  final Random dartRandom;

  const DartRandom(this.dartRandom);

  String get algorithmName => 'DartRandom';

  /// Generates a random BigInt with the specified bit length.
  ///
  /// Parameters:
  /// - [bitLength]: The number of bits in the resulting BigInt.
  ///
  /// Returns a random BigInt with [bitLength] bits.
  ///
  /// Example:
  /// ```dart
  /// final random = DartRandom(Random.secure());
  /// final bigInt = random.nextBigInteger(256);
  /// print(bigInt.bitLength); // Prints a number close to 256
  /// ```
  BigInt nextBigInteger(int bitLength) {
    final int fullBytes = bitLength ~/ 8;
    // Generate a number from the full bytes.
    // Then, prepend a smaller number covering the remaining bits.
    final BigInt main = bytesToInt(nextBytes(fullBytes));
    // Forcing remaining bits to be calculate with bits length.
    final int remainingBits = bitLength - main.bitLength;
    final int additional = remainingBits < 4
        ? dartRandom.nextInt(pow(2, remainingBits).toInt())
        : remainingBits;
    final BigInt additionalBit = BigInt.from(additional) << (fullBytes * 8);
    final BigInt result = main + additionalBit;
    return result;
  }

  /// Generates a Uint8List of random bytes.
  ///
  /// Parameters:
  /// - [count]: The number of random bytes to generate.
  ///
  /// Returns a Uint8List containing [count] random bytes.
  ///
  /// Example:
  /// ```dart
  /// final random = DartRandom(Random.secure());
  /// final bytes = random.nextBytes(16);
  /// print(bytes.length); // Prints: 16
  /// ```
  Uint8List nextBytes(int count) {
    return Uint8List.fromList(List.generate(count, (_) => nextUint8()));
  }

  /// Generates a random 16-bit unsigned integer.
  ///
  /// Returns a random integer between 0 and 65535 (inclusive).
  ///
  /// Example:
  /// ```dart
  /// final random = DartRandom(Random.secure());
  /// final uint16 = random.nextUint16();
  /// print(uint16 >= 0 && uint16 <= 65535); // Prints: true
  /// ```
  int nextUint16() => dartRandom.nextInt(pow(2, 32).toInt());

  /// Generates a random 32-bit unsigned integer.
  ///
  /// Returns a random integer between 0 and 4294967295 (inclusive).
  ///
  /// Example:
  /// ```dart
  /// final random = DartRandom(Random.secure());
  /// final uint32 = random.nextUint32();
  /// print(uint32 >= 0 && uint32 <= 4294967295); // Prints: true
  /// ```
  int nextUint32() => dartRandom.nextInt(pow(2, 32).toInt());

  /// Generates a random 8-bit unsigned integer.
  ///
  /// Returns a random integer between 0 and 255 (inclusive).
  ///
  /// Example:
  /// ```dart
  /// final random = DartRandom(Random.secure());
  /// final uint8 = random.nextUint8();
  /// print(uint8 >= 0 && uint8 <= 255); // Prints: true
  /// ```
  int nextUint8() => dartRandom.nextInt(pow(2, 8).toInt());
}

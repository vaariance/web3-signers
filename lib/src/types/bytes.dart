part of '../../web3_signers.dart';

typedef Bytes = Uint8List;

extension BytesX on Bytes {
  /// Checks if this Bytes is equal to another Bytes.
  ///
  /// Parameters:
  /// - [other]: The Bytes to compare with.
  ///
  /// Returns true if the Bytess are equal, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final list1 = Bytes.fromList([1, 2, 3]);
  /// final list2 = Bytes.fromList([1, 2, 3]);
  /// print(list1.eq(list2)); // Prints: true
  /// ```
  bool eq(Bytes other) {
    bool equals(Object? e1, Object? e2) => e1 == e2;
    if (identical(this, other)) return true;
    var length = this.length;
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (!equals(this[i], other[i])) return false;
    }
    return true;
  }

  /// Concatenates this Bytes with another Bytes.
  ///
  /// Parameters:
  /// - [other]: The Bytes to concatenate with.
  ///
  /// Returns a new Bytes containing the elements of this list followed by the elements of [other].
  ///
  /// Example:
  /// ```dart
  /// final list1 = Bytes.fromList([1, 2]);
  /// final list2 = Bytes.fromList([3, 4]);
  /// final result = list1.concat(list2);
  /// print(result); // Prints: [1, 2, 3, 4]
  /// ```
  Bytes concat(Bytes other) {
    final result = Bytes(length + other.length);
    result.setRange(0, length, this);
    result.setRange(length, length + other.length, other);
    return result;
  }

  /// Pads this Bytes to n bytes by adding zeros to the left.
  ///
  /// Returns a new Bytes of n bytes with this list's elements right-aligned.
  ///
  /// Throws an ArgumentError if this list is longer than n bytes.
  ///
  /// Example:
  /// ```dart
  /// final list = Bytes.fromList([1, 2, 3]);
  /// final padded = list.padLeft(); // default 32
  /// print(padded.length); // Prints: 32
  /// print(padded.sublist(29)); // Prints: [1, 2, 3]
  /// ```
  Bytes padLeft([int n = 32]) {
    if (length > n) {
      throw ArgumentError('Bytes length exceeds 32 bytes.');
    }
    if (length == n) {
      return Bytes.fromList(this);
    }
    return Bytes(n)..setRange(n - length, n, this);
  }

  /// Pads this Bytes to n bytes by adding zeros to the right.
  ///
  /// Returns a new Bytes of n bytes with this list's elements left-aligned.
  ///
  /// Throws an ArgumentError if this list is longer than n bytes.
  ///
  /// Example:
  /// ```dart
  /// final list = Bytes.fromList([1, 2, 3]);
  /// final padded = list.padRight(); // default 32
  /// print(padded.length); // Prints: 32
  /// print(padded.sublist(0, 3)); // Prints: [1, 2, 3]
  /// ```
  Bytes padRight([int n = 32]) {
    if (length > n) {
      throw ArgumentError('Bytes length exceeds 32 bytes.');
    }
    if (length == n) {
      return Bytes.fromList(this);
    }
    return Bytes(n)..setRange(0, length, this);
  }

  HexString toHex() => hexlify(this);

  /// Applies a function to this Bytes and returns the result.
  ///
  /// Parameters:
  /// - [block]: A function that takes a Bytes and returns a value of type R.
  ///
  /// Returns the result of applying [block] to this Bytes.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// final sum = list.let((it) => it.reduce((a, b) => a + b));
  /// print(sum); // Prints: 6
  /// ```
  R? let<R>(R Function(Bytes) block) => block(this);
}

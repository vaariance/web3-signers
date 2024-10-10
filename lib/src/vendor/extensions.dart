part of 'vendor.dart';

typedef BinaryBlob = Uint8List;

enum BlobType { binary, der, nonce, requestId }

extension ExtBinaryBlob on BinaryBlob {
  /// Returns the blob type as BinaryBlob.
  BlobType get blobType => BlobType.binary;

  /// Returns the length of the blob in bytes.
  int get byteLength => lengthInBytes;

  /// Returns the name of the blob, which is always '__BLOB'.
  String get name => '__BLOB';

  /// Creates a new Uint8List from another Uint8List.
  ///
  /// Parameters:
  /// - [other]: The Uint8List to copy from.
  ///
  /// Returns a new Uint8List with the same content as [other].
  ///
  /// Example:
  /// ```dart
  /// final original = Uint8List.fromList([1, 2, 3]);
  /// final copy = ExtBinaryBlob.from(original);
  /// print(copy); // Prints: [1, 2, 3]
  /// ```
  static Uint8List from(Uint8List other) => Uint8List.fromList(other);
}

extension TupleExtension on Tuple {
  /// Converts the Tuple to a List.
  ///
  /// Returns a List containing the two items of the Tuple.
  ///
  /// Example:
  /// ```dart
  /// final tuple = Tuple(1, 'a');
  /// final list = tuple.toList();
  /// print(list); // Prints: [1, 'a']
  /// ```
  List toList() {
    return [item1, item2];
  }
}

extension U8aExtension on Uint8List {
  /// Checks if this Uint8List is equal to another Uint8List.
  ///
  /// Parameters:
  /// - [other]: The Uint8List to compare with.
  ///
  /// Returns true if the Uint8Lists are equal, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final list1 = Uint8List.fromList([1, 2, 3]);
  /// final list2 = Uint8List.fromList([1, 2, 3]);
  /// print(list1.eq(list2)); // Prints: true
  /// ```
  bool eq(Uint8List other) {
    bool equals(Object? e1, Object? e2) => e1 == e2;
    if (identical(this, other)) return true;
    var length = this.length;
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (!equals(this[i], other[i])) return false;
    }
    return true;
  }

  /// Concatenates this Uint8List with another Uint8List.
  ///
  /// Parameters:
  /// - [other]: The Uint8List to concatenate with.
  ///
  /// Returns a new Uint8List containing the elements of this list followed by the elements of [other].
  ///
  /// Example:
  /// ```dart
  /// final list1 = Uint8List.fromList([1, 2]);
  /// final list2 = Uint8List.fromList([3, 4]);
  /// final result = list1.concat(list2);
  /// print(result); // Prints: [1, 2, 3, 4]
  /// ```
  Uint8List concat(Uint8List other) {
    final result = Uint8List(length + other.length);
    result.setRange(0, length, this);
    result.setRange(length, length + other.length, other);
    return result;
  }

  /// Applies a function to this Uint8List and returns the result.
  ///
  /// Parameters:
  /// - [block]: A function that takes a Uint8List and returns a value of type R.
  ///
  /// Returns the result of applying [block] to this Uint8List.
  ///
  /// Example:
  /// ```dart
  /// final list = Uint8List.fromList([1, 2, 3]);
  /// final sum = list.let((it) => it.reduce((a, b) => a + b));
  /// print(sum); // Prints: 6
  /// ```
  R? let<R>(R Function(Uint8List) block) => block(this);

  /// Pads this Uint8List to 32 bytes by adding zeros to the left.
  ///
  /// Returns a new Uint8List of 32 bytes with this list's elements right-aligned.
  ///
  /// Throws an ArgumentError if this list is longer than 32 bytes.
  ///
  /// Example:
  /// ```dart
  /// final list = Uint8List.fromList([1, 2, 3]);
  /// final padded = list.padLeftTo32Bytes();
  /// print(padded.length); // Prints: 32
  /// print(padded.sublist(29)); // Prints: [1, 2, 3]
  /// ```
  Uint8List padLeftTo32Bytes() {
    if (length > 32) {
      throw ArgumentError('Uint8List length exceeds 32 bytes.');
    }
    if (length == 32) {
      return this;
    }
    final padded = Uint8List(32);
    padded.setRange(32 - length, 32, this);
    return padded;
  }

  /// Pads this Uint8List to 32 bytes by adding zeros to the right.
  ///
  /// Returns a new Uint8List of 32 bytes with this list's elements left-aligned.
  ///
  /// Throws an ArgumentError if this list is longer than 32 bytes.
  ///
  /// Example:
  /// ```dart
  /// final list = Uint8List.fromList([1, 2, 3]);
  /// final padded = list.padRightTo32Bytes();
  /// print(padded.length); // Prints: 32
  /// print(padded.sublist(0, 3)); // Prints: [1, 2, 3]
  /// ```
  Uint8List padRightTo32Bytes() {
    if (length > 32) {
      throw ArgumentError('Uint8List length exceeds 32 bytes.');
    }
    if (length == 32) {
      return this;
    }
    final padded = Uint8List(32);
    padded.setRange(0, length, this);
    return padded;
  }
}

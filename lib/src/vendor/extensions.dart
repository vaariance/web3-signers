part of 'vendor.dart';

typedef BinaryBlob = Uint8List;

enum BlobType { binary, der, nonce, requestId }

extension ExtBinaryBlob on BinaryBlob {
  BlobType get blobType => BlobType.binary;

  int get byteLength => lengthInBytes;

  String get name => '__BLOB';

  static Uint8List from(Uint8List other) => Uint8List.fromList(other);
}

extension StringExtension on String {
  Uint8List toU8a({int bitLength = -1}) => hexToU8a(this, bitLength);
}

extension TupleExtension on Tuple {
  List toList() {
    return [item1, item2];
  }
}

extension U8aExtension on Uint8List {
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
}

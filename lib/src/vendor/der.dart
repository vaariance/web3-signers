part of 'vendor.dart';

/// OID for the P-256 elliptic curve.
///
/// This constant represents the Object Identifier (OID) for the P-256 elliptic curve
/// (1.2.840.10045.3.1.7) in DER-encoded format.
final oidP256 = Uint8List.fromList([
  ...[0x30, 0x13],
  ...[0x06, 0x07], // OID with 7 bytes
  ...[0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01], // SEQUENCE
  ...[0x06, 0x08], // OID with 8 bytes
  ...[0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07]
]);

/// Compares two ByteBuffers for equality.
///
/// Parameters:
/// - [b1]: The first ByteBuffer to compare.
/// - [b2]: The second ByteBuffer to compare.
///
/// Returns true if the buffers are equal, false otherwise.
///
/// Example:
/// ```dart
/// final buffer1 = Uint8List.fromList([1, 2, 3]).buffer;
/// final buffer2 = Uint8List.fromList([1, 2, 3]).buffer;
/// print(bufEquals(buffer1, buffer2)); // Prints: true
/// ```
bool bufEquals(ByteBuffer b1, ByteBuffer b2) {
  if (b1.lengthInBytes != b2.lengthInBytes) return false;
  final u1 = Uint8List.fromList(b1.asUint8List());
  final u2 = Uint8List.fromList(b2.asUint8List());
  for (int i = 0; i < u1.length; i++) {
    if (u1[i] != u2[i]) {
      return false;
    }
  }
  return true;
}

/// Extracts a payload from DER-encoded data and verifies its OID.
///
/// This function decodes DER-encoded data of the form:
/// `SEQUENCE(oid, BITSTRING(payload))`
///
/// Parameters:
/// - [derEncoded]: The DER-encoded data to unwrap.
/// - [oid]: The expected OID in DER-encoded format.
///
/// Returns the unwrapped payload as a Uint8List.
///
/// Throws:
/// - ArgumentError if the DER structure is invalid.
/// - StateError if the OID doesn't match the expected value.
///
/// Example:
/// ```dart
/// final derData = Uint8List.fromList([...]);  // DER-encoded data
/// final unwrappedPayload = bytesUnwrapDer(derData, oidP256);
/// ```
Uint8List bytesUnwrapDer(Uint8List derEncoded, Uint8List oid) {
  int offset = 0;
  final buf = Uint8List.fromList(derEncoded);

  void check(int expected, String name) {
    if (buf[offset] != expected) {
      throw ArgumentError.value(
        buf[offset],
        name,
        'Expected $expected for $name but got',
      );
    }
    offset++;
  }

  check(0x30, 'sequence');
  offset += decodeLenBytes(buf, offset);
  if (!bufEquals(
    buf.sublist(offset, offset + oid.lengthInBytes).buffer,
    oid.buffer,
  )) {
    throw StateError('Not the expecting OID.');
  }
  offset += oid.lengthInBytes;
  check(0x03, 'bit string');
  offset += decodeLenBytes(buf, offset);
  check(0x00, '0 padding');
  return buf.sublist(offset);
}

/// Unwraps a DER-encoded ECDSA signature.
///
/// This function decodes a DER-encoded ECDSA signature of the form:
/// `0x30|b1|0x02|b2|r|0x02|b3|s`
///
/// Parameters:
/// - [derEncoded]: The DER-encoded signature to unwrap.
///
/// Returns the unwrapped signature as a 64-byte Uint8List (32 bytes for r, 32 bytes for s).
///
/// Throws an error if the DER structure is invalid.
///
/// Example:
/// ```dart
/// final derSignature = Uint8List.fromList([...]);  // DER-encoded signature
/// final rawSignature = bytesUnwrapDerSignature(derSignature);
/// ```
List<Uint8List> bytesUnwrapDerSignature(Uint8List derEncoded) {
  if (derEncoded.length == 64) {
    throw "Signature is not DER-encoded";
  }

  final buf = Uint8List.fromList(derEncoded);

  const splitter = 0x02;
  final b1 = buf[1];

  if (b1 != buf.length - 2) {
    throw 'Bytes long is not correct';
  }
  if (buf[2] != splitter) {
    throw 'Splitter not found';
  }

  Tuple<int, Uint8List> getBytes(Uint8List remaining) {
    int length = 0;
    Uint8List bytes;

    if (remaining[0] != splitter) {
      throw 'Splitter not found';
    }
    if (remaining[1] > 32) {
      if (remaining[2] != 0x0 || remaining[3] <= 0x80) {
        throw 'r value is not correct';
      } else {
        length = remaining[1];
        bytes = remaining.sublist(3, 2 + length);
      }
    } else {
      length = remaining[1];
      bytes = remaining.sublist(2, 2 + length);
    }
    return Tuple(length, bytes);
  }

  final rRemaining = buf.sublist(2);
  final rBytes = getBytes(rRemaining);
  final b2 = rBytes.item1;
  final r = Uint8List.fromList(rBytes.item2);
  final sRemaining = rRemaining.sublist(b2 + 2);

  final sBytes = getBytes(sRemaining);
  // final b3 = sBytes.item1;
  final s = Uint8List.fromList(sBytes.item2);
  return [r, s];
}

/// Wraps a payload in DER encoding with a specified OID.
///
/// This function encodes data in the form:
/// `SEQUENCE(oid, BITSTRING(payload))`
///
/// Parameters:
/// - [payload]: The payload to encode as a bit string.
/// - [oid]: The OID to tag the payload with (in DER-encoded format).
///
/// Returns the DER-encoded data as a Uint8List.
///
/// Example:
/// ```dart
/// final payload = Uint8List.fromList([1, 2, 3, 4]);
/// final derEncoded = bytesWrapDer(payload, oidP256);
/// ```
Uint8List bytesWrapDer(Uint8List payload, Uint8List oid) {
  // The header needs to include the unused bit count byte in its length.
  final bitStringHeaderLength = 2 + encodeLenBytes(payload.lengthInBytes + 1);
  final len = oid.lengthInBytes + bitStringHeaderLength + payload.lengthInBytes;
  int offset = 0;
  final buf = Uint8List(1 + encodeLenBytes(len) + len);
  // Sequence.
  buf[offset++] = 0x30;
  // Sequence Length.
  offset += encodeLen(buf, offset, len);
  // OID.
  buf.setAll(offset, oid);
  offset += oid.lengthInBytes;
  // Bit String Header.
  buf[offset++] = 0x03;
  offset += encodeLen(buf, offset, payload.lengthInBytes + 1);
  // 0 padding.
  buf[offset++] = 0x00;
  buf.setAll(offset, Uint8List.fromList(payload));
  return buf;
}

/// Wraps a raw ECDSA signature in DER encoding.
///
/// Parameters:
/// - [rawSignature]: The raw signature to encode (must be 64 bytes: 32 for r, 32 for s).
///
/// Returns the DER-encoded signature as a Uint8List.
///
/// Throws an error if the raw signature is not 64 bytes long.
///
/// Example:
/// ```dart
/// final rawSignature = Uint8List(64);  // 64-byte raw signature
/// final derSignature = bytesWrapDerSignature(rawSignature);
/// ```
Uint8List bytesWrapDerSignature(List<Uint8List> rawSignature) {
  if (rawSignature[0].length != 32 || rawSignature[1].length != 32) {
    throw 'Raw signature length has to be length 64';
  }

  final r = rawSignature[0];
  final s = rawSignature[1];

  Uint8List joinBytes(Uint8List arr) {
    if (arr[0] > 0x80) {
      return Uint8List.fromList([0x02, 0x21, 0x0, ...arr]);
    } else {
      return Uint8List.fromList([0x02, 0x20, ...arr]);
    }
  }

  final rBytes = joinBytes(r);
  final sBytes = joinBytes(s);

  final b1 = rBytes.length + sBytes.length;

  return Uint8List.fromList([0x30, b1, ...rBytes, ...sBytes]);
}

/// Decodes the number of bytes used to encode the length in DER format.
///
/// Parameters:
/// - [buf]: The buffer containing the DER-encoded data.
/// - [offset]: The offset in the buffer where the length starts.
///
/// Returns the number of bytes used to encode the length.
///
/// Throws:
/// - ArgumentError if the length encoding is invalid.
/// - RangeError if the length is too long to be represented.
///
/// Example:
/// ```dart
/// final derData = Uint8List.fromList([0x82, 0x01, 0x23]);  // Length 291 encoded in 2 bytes
/// final lenBytes = decodeLenBytes(derData, 0);
/// print(lenBytes);  // Prints: 3
/// ```
int decodeLenBytes(Uint8List buf, int offset) {
  if (buf[offset] < 0x80) {
    return 1;
  }
  if (buf[offset] == 0x80) {
    throw ArgumentError.value(buf[offset], 'length', 'Invalid length');
  }
  if (buf[offset] == 0x81) {
    return 2;
  }
  if (buf[offset] == 0x82) {
    return 3;
  }
  if (buf[offset] == 0x83) {
    return 4;
  }
  throw RangeError.range(
    buf[offset],
    null,
    0xffffff,
    'length',
    'Length is too long',
  );
}

/// Encodes a length value into DER format.
///
/// Parameters:
/// - [buf]: The buffer to write the encoded length into.
/// - [offset]: The offset in the buffer to start writing.
/// - [len]: The length value to encode.
///
/// Returns the number of bytes written.
///
/// Throws:
/// - RangeError if the length is too long to be represented in DER format.
///
/// Example:
/// ```dart
/// final buf = Uint8List(4);
/// final bytesWritten = encodeLen(buf, 0, 291);
/// print(bytesWritten);  // Prints: 3
/// print(buf.sublist(0, bytesWritten));  // Prints: [0x82, 0x01, 0x23]
/// ```
int encodeLen(Uint8List buf, int offset, int len) {
  if (len <= 0x7f) {
    buf[offset] = len;
    return 1;
  } else if (len <= 0xff) {
    buf[offset] = 0x81;
    buf[offset + 1] = len;
    return 2;
  } else if (len <= 0xffff) {
    buf[offset] = 0x82;
    buf[offset + 1] = len >> 8;
    buf[offset + 2] = len;
    return 3;
  } else if (len <= 0xffffff) {
    buf[offset] = 0x83;
    buf[offset + 1] = len >> 16;
    buf[offset + 2] = len >> 8;
    buf[offset + 3] = len;
    return 4;
  }
  throw RangeError.range(len, null, 0xffffff, 'length', 'Length is too long');
}

/// Calculates the number of bytes needed to encode a length value in DER format.
///
/// Parameters:
/// - [len]: The length value to encode.
///
/// Returns the number of bytes needed to encode the length.
///
/// Throws:
/// - RangeError if the length is too long to be represented in DER format.
///
/// Example:
/// ```dart
/// final bytesNeeded = encodeLenBytes(291);
/// print(bytesNeeded);  // Prints: 3
/// ```
int encodeLenBytes(int len) {
  if (len <= 0x7f) {
    return 1;
  } else if (len <= 0xff) {
    return 2;
  } else if (len <= 0xffff) {
    return 3;
  } else if (len <= 0xffffff) {
    return 4;
  }
  throw RangeError.range(len, null, 0xffffff, 'length', 'Length is too long');
}

/// Checks if a given byte sequence is a valid DER-encoded public key with the specified OID.
///
/// Parameters:
/// - [pub]: The byte sequence to check.
/// - [oid]: The expected OID in DER-encoded format.
///
/// Returns true if the byte sequence is a valid DER-encoded public key with the given OID, false otherwise.
///
/// Example:
/// ```dart
/// final pubKeyBytes = Uint8List.fromList([...]);  // DER-encoded public key
/// final isValid = isDerPublicKey(pubKeyBytes, oidP256);
/// print(isValid);  // Prints: true or false
/// ```
bool isDerPublicKey(Uint8List pub, Uint8List oid) {
  final oidLength = oid.length;
  if (!pub.sublist(0, oidLength).eq(oid)) {
    return false;
  } else {
    try {
      return bytesWrapDer(bytesUnwrapDer(pub, oid), oid).eq(pub);
    } catch (e) {
      return false;
    }
  }
}

/// Checks if a given byte sequence is a valid DER-encoded ECDSA signature.
///
/// Parameters:
/// - [sig]: The byte sequence to check.
///
/// Returns true if the byte sequence is a valid DER-encoded ECDSA signature, false otherwise.
///
/// Example:
/// ```dart
/// final sigBytes = Uint8List.fromList([...]);  // DER-encoded signature
/// final isValid = isDerSignature(sigBytes);
/// print(isValid);  // Prints: true or false
/// ```
bool isDerSignature(Uint8List sig) {
  try {
    return bytesWrapDerSignature(bytesUnwrapDerSignature(sig)).eq(sig);
  } catch (e) {
    return false;
  }
}

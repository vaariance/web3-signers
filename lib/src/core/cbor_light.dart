part of '../../web3_signers.dart';

/// Extracts data for `pattern` from a CBOR map.
///
/// - Scans CBOR for the text key matching `pattern` and reads its Byte String value.
/// - Supports definite-length Byte Strings with 1/2/4-byte length headers.
/// - Returns `null` if the key isn’t found or if decoding fails.
///
/// Parameters:
/// - [object]: CBOR-encoded `attestationObject` as bytes.
/// - [searchPattern]: The pattern to search for.
///
/// Returns:
/// - `Bytes?` containing data found for `pattern`.
Bytes? extractCBORPattern(
  Bytes object, [
  List<int> searchPattern = authDataPattern,
]) {
  final index = _findPatternIndex(object, searchPattern);
  if (index == -1) return null;

  // offset is index + length of header "authData"
  final offset = index + searchPattern.length;
  if (offset >= object.length) return null;

  return _decodeCBORByteString(object, offset);
}

/// Finds the first index of `pattern` in `data`, or `-1` if not found.
int _findPatternIndex(Bytes data, List<int> pattern) {
  for (int i = 0; i <= data.length - pattern.length; i++) {
    bool match = true;
    for (int j = 0; j < pattern.length; j++) {
      if (data[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

/// Decodes a CBOR Byte String starting at `offset`.
///
/// Supports definite-length headers:
/// - `0x40..0x57` (length 0–23)
/// - `0x58` (next 1 byte is length)
/// - `0x59` (next 2 bytes are length, big-endian)
/// - `0x5A` (next 4 bytes are length, big-endian)
///
/// Returns `null` for unsupported forms or invalid bounds.
Bytes? _decodeCBORByteString(Bytes data, int offset) {
  int header = data[offset];
  int length = 0;
  int dataStart = 0;

  if (header >= 0x40 && header <= 0x57) {
    // Length 0-23
    length = header - 0x40;
    dataStart = offset + 1;
  } else if (header == 0x58) {
    // 1-byte extension
    if (offset + 1 >= data.length) return null;
    length = data[offset + 1];
    dataStart = offset + 2;
  } else if (header == 0x59) {
    // 2-byte extension
    if (offset + 2 >= data.length) return null;
    length = (data[offset + 1] << 8) | data[offset + 2];
    dataStart = offset + 3;
  } else if (header == 0x5A) {
    // 4-byte extension
    if (offset + 4 >= data.length) return null;
    length =
        (data[offset + 1] << 24) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 8) |
        data[offset + 4];
    dataStart = offset + 5;
  } else {
    // Unsupported length
    return null;
  }

  if (dataStart + length > data.length) return null;

  return data.sublist(dataStart, dataStart + length);
}

/// Extracts 32-byte X and Y coordinates from a COSE_Key-encoded EC public key.
///
/// - COSE_Key labels for EC2 keys: `-2` (x) and `-3` (y).
/// - This function is a lightweight scanner that looks for `0x21 0x58 0x20` (label -2, 32-byte)
///   and `0x22 0x58 0x20` (label -3, 32-byte), then slices the following 32 bytes.
/// - Returns `null` if either component is missing.
///
/// Parameters:
/// - [pubKeyData]: CBOR-encoded COSE_Key bytes.
///
/// Returns:
/// - `PublicKey?` tuple with `{ x: Uint256, y: Uint256 }`.
(Uint256, Uint256)? extractXYFromCoseKey(Bytes pubKeyData) {
  // Key -2 (X): 0x21. Value: Byte String (0x58) Length 32 (0x20)
  final n2 = [0x21, 0x58, 0x20];
  // Key -3 (Y): 0x22. Value: Byte String (0x58) Length 32 (0x20)
  final n3 = [0x22, 0x58, 0x20];

  final x = _findAndExtract(n2, pubKeyData);
  final y = _findAndExtract(n3, pubKeyData);

  if (x != null && y != null) {
    return (Uint256.fromBytes(x), Uint256.fromBytes(y));
  }
  return null;
}

/// Finds `pattern` in `pubKeyData` and returns the next 32 bytes.
Bytes? _findAndExtract(List<int> pattern, Bytes pubKeyData) {
  for (int i = 0; i <= pubKeyData.length - pattern.length - 32; i++) {
    bool match = true;
    for (int j = 0; j < pattern.length; j++) {
      if (pubKeyData[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      return pubKeyData.sublist(i + pattern.length, i + pattern.length + 32);
    }
  }
  return null;
}

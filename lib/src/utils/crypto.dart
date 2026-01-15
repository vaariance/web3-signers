/// Crypto and encoding utilities used by web3-signers.
///
/// This module provides helpers for:
/// - Base64 URL-safe encoding/decoding utilities.
/// - Generic hex and hashing helpers.
///
/// The functions here favor simple, allocation-friendly operations on `Bytes`
/// (alias for byte arrays) and `Uint256` primitives. Where relevant, edge cases
/// and error conditions are documented explicitly.
part of '../../web3_signers.dart';

/// Generates cryptographically secure random bytes.
///
/// - Uses `Random.secure()` under the hood.
/// - Returns a `List<int>` of length `length` containing values in `[0, 255]`.
///
/// Parameters:
/// - [length]: Number of random bytes to generate. Defaults to `32`.
///
/// Returns:
/// - `List<int>` of random bytes.
///
/// Example:
/// ```dart
/// final bytes = getRandomValues(16);
/// assert(bytes.length == 16);
/// ```
List<int> getRandomValues([int length = 32]) {
  final random = Random.secure();
  return List<int>.generate(length, (i) => random.nextInt(256));
}

/// Parses a DER/ASN.1-encoded ECDSA signature and returns `(r, s)` as `Uint256`.
///
/// - Expects a DER SEQUENCE of two INTEGERs (RFC 5280 style): `SEQUENCE(INTEGER r, INTEGER s)`.
/// - Removes a leading `0x00` from each INTEGER when present to avoid negative sign interpretation.
/// - Does not compute or include `v`/recovery id; this is strictly `(r, s)`.
///
/// Parameters:
/// - [signatureBytes]: DER/ASN.1-encoded ECDSA signature as bytes.
///
/// Returns:
/// - Tuple `({ r: Uint256, s: Uint256 })`.
///
/// Throws:
/// - `Exception('Invalid signature bytes')` if structure or values are invalid.
///
/// Example:
/// ```dart
/// final sig = Bytes.fromList([0x30, /* ... */]);
/// final (r: r, s: s) = getMessagingSignature(sig);
/// ```
({Uint256 r, Uint256 s}) getMessagingSignature(Bytes signatureBytes) {
  final parser = ASN1Parser(signatureBytes);
  final parsedSignature = parser.nextObject() as ASN1Sequence;
  final rValue = parsedSignature.elements![0];
  final sValue = parsedSignature.elements![1];

  var rBytes = rValue.valueBytes;
  var sBytes = sValue.valueBytes;

  if (rBytes == null || sBytes == null || rBytes.isEmpty || sBytes.isEmpty) {
    throw Exception('Invalid signature bytes');
  }

  if (shouldRemoveLeadingZero(rBytes)) {
    rBytes = rBytes.sublist(1);
  }
  if (shouldRemoveLeadingZero(sBytes)) {
    sBytes = sBytes.sublist(1);
  }

  final r = hexlify(rBytes);
  final s = hexlify(sBytes);
  return (r: Uint256.fromHex(r), s: Uint256.fromHex(s));
}

/// Converts bytes (`List<int>`) to a hex string with `0x` prefix.
///
/// Parameters:
/// - [intArray]: Bytes to convert.
///
/// Returns:
/// - Hex string like `0x01ff`.
///
/// Example:
/// ```dart
/// final h = hexlify([1, 15, 255]);
/// assert(h == '0x010fff');
/// ```
String hexlify(List<int> intArray) {
  var ss = <String>[];
  for (int value in intArray) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

/// Computes the SHA-256 digest of `input`.
///
/// Parameters:
/// - [input]: Byte list to hash.
///
/// Returns:
/// - `Bytes` digest (32 bytes).
///
/// Example:
/// ```dart
/// final hash = sha256Hash(utf8.encode('Hello, World!'));
/// ```
Bytes sha256Hash(List<int> input) {
  final digest = SHA256Digest();
  return digest.process(Bytes.fromList(input));
}

/// Returns `true` when a leading `0x00` should be stripped from a DER INTEGER.
///
/// In ASN.1 DER, INTEGERs are encoded as two’s-complement. A leading `0x00`
/// is used to indicate a positive value when the most significant bit would
/// otherwise be set. For ECDSA `r`/`s` parsing, stripping this prefix avoids
/// negative interpretation.
///
/// Parameters:
/// - [bytes]: Encoded INTEGER bytes.
///
/// Returns:
/// - `true` if the first byte is `0x00` and the next byte has the MSB set.
bool shouldRemoveLeadingZero(Bytes bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

/// Pads a Base64/Base64URL string with `=` so its length is a multiple of 4.
///
/// Useful when decoding Base64URL inputs that omit padding.
///
/// Parameters:
/// - [b64]: Base64 or Base64URL string (possibly without padding).
///
/// Returns:
/// - Padded string.
String padBase64(String b64) {
  final padding = 4 - b64.length % 4;
  return padding < 4 ? '$b64${"=" * padding}' : b64;
}

/// Decodes a URL-safe Base64 string into bytes.
///
/// - Adds `=` padding as needed before decoding.
/// - Uses Base64URL alphabet.
///
/// Parameters:
/// - [b64]: Base64URL string.
///
/// Returns:
/// - Decoded bytes.
Bytes b64d(String b64) => base64Url.decode(padBase64(b64));

/// Encodes bytes into a URL-safe Base64 string without padding.
///
/// - Uses Base64URL alphabet.
/// - Strips any trailing `=` characters.
///
/// Parameters:
/// - [bytes]: Bytes to encode.
///
/// Returns:
/// - Base64URL string.
String b64e(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

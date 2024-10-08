part of 'utils.dart';

RegExp _hexadecimal = RegExp(r'^[0-9a-fA-F]+$');

/// Converts a hex string to a 32bytes `Uint8List`.
///
/// Parameters:
/// - [hexString]: The input hex string.
///
/// Returns a Uint8List containing the converted bytes.
///
/// Example:
/// ```dart
/// final hexString = '0x1a2b3c';
/// final resultBytes = arrayify(hexString);
/// ```
Uint8List arrayify(String hexString) {
  hexString = hexString.replaceAll(RegExp(r'\s+'), '');
  List<int> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String byteHex = hexString.substring(i, i + 2);
    int byteValue = int.parse(byteHex, radix: 16);
    bytes.add(byteValue);
  }
  return Uint8List.fromList(bytes);
}

/// Retrieves the X and Y components of an ECDSA public key from its bytes.
///
/// Parameters:
/// - [publicKeyBytes]: The bytes of the ECDSA public key.
///
/// Returns a Future containing a Tuple of two uint256 values representing the X and Y components of the public key.
///
/// Example:
/// ```dart
/// final publicKeyBytes = Uint8List.fromList([4, 1, 2, 3]); // Replace with actual public key bytes
/// final components = await getPublicKeyFromBytes(publicKeyBytes);
/// log(components); // Output: ['01', '02']
/// ```
Future<Tuple<Uint256, Uint256>> getPublicKeyFromBytes(
    Uint8List publicKeyBytes) async {
  final pKey = bytesUnwrapDer(publicKeyBytes, oidP256).sublist(1);
  final decodedX = pKey.sublist(0, 32);
  final decodedY = pKey.sublist(32, 64);
  return Tuple(Uint256.fromList(decodedX), Uint256.fromList(decodedY));
}

/// Parses ASN1-encoded signature bytes and returns a List of two hex strings representing the `r` and `s` values.
///
/// Parameters:
/// - [signatureBytes]: Uint8List containing the ASN1-encoded signature bytes.
///
/// Returns a Future<List<String>> containing hex strings for `r` and `s` values.
///
/// Example:
/// ```dart
/// final signatureBytes = Uint8List.fromList([48, 68, 2, 32, ...]);
/// final signatureHexValues = await getMessagingSignature(signatureBytes);
/// ```
Tuple<Uint256, Uint256> getMessagingSignature(Uint8List signatureBytes) {
  final sig = bytesUnwrapDerSignature(signatureBytes);
  return Tuple(
    Uint256.fromList(sig[0]),
    Uint256.fromList(sig[1]),
  );
}

/// Converts a list of integers to a hexadecimal string.
///
/// Parameters:
/// - [intArray]: The list of integers to be converted.
///
/// Returns a string representing the hexadecimal value.
///
/// Example:
/// ```dart
/// final intArray = [1, 15, 255];
/// final hexString = hexlify(intArray);
/// log(hexString); // Output: '0x01ff'
/// ```
String hexlify(List<int> intArray) {
  var ss = <String>[];
  for (int value in intArray) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

/// Throws an exception if the specified requirement is not met.
///
/// Parameters:
/// - [requirement]: The boolean requirement to be checked.
/// - [exception]: The exception message to be thrown if the requirement is not met.
///
/// Throws an exception with the specified message if the requirement is not met.
///
/// Example:
/// ```dart
/// final value = 42;
/// require(value > 0, "Value must be greater than 0");
/// log("Value is valid: $value");
/// ```
require(bool requirement, String exception) {
  if (!requirement) {
    throw Exception(exception);
  }
}

/// Computes the SHA-256 hash of the specified input.
///
/// Parameters:
/// - [input]: The list of integers representing the input data.
///
/// Returns a [Digest] object representing the SHA-256 hash.
///
/// Example:
/// ```dart
/// final data = utf8.encode("Hello, World!");
/// final hash = sha256Hash(data);
/// log("SHA-256 Hash: ${hash.toString()}");
/// ```
List<int> sha256Hash(List<int> input) {
  return SHA256.hash(input);
}

/// Checks whether the leading zero should be removed from the byte array.
///
/// Parameters:
/// - [bytes]: The list of integers representing the byte array.
///
/// Returns `true` if the leading zero should be removed, otherwise `false`.
///
/// Example:
/// ```dart
/// final byteData = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
/// final removeZero = shouldRemoveLeadingZero(byteData);
/// log("Remove Leading Zero: $removeZero");
/// ```
bool shouldRemoveLeadingZero(Uint8List bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

/// Combines multiple lists of integers into a single list.
///
/// Parameters:
/// - [buff]: List of lists of integers to be combined.
///
/// Returns a new list containing all the integers from the input lists.
///
/// Example:
/// ```dart
/// final list1 = [1, 2, 3];
/// final list2 = [4, 5, 6];
/// final combinedList = toBuffer([list1, list2]);
/// log("Combined List: $combinedList");
/// ```
List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}

/// Pads a Base64 string with '=' characters to ensure its length is a multiple of 4.
///
/// Parameters:
/// - [b64]: The Base64 string to pad.
///
/// Returns the padded Base64 string.
///
/// Example:
/// ```dart
/// final paddedB64 = padBase64('SGVsbG8gV29ybGQ');
/// print(paddedB64); // Prints: SGVsbG8gV29ybGQ=
/// ```
String padBase64(String b64) {
  final padding = 4 - b64.length % 4;
  return padding < 4 ? '$b64${"=" * padding}' : b64;
}

/// Decodes a Base64 URL encoded string, adding any required '=' padding.
///
/// Parameters:
/// - [b64]: The Base64 URL encoded string to decode.
///
/// Returns a Uint8List containing the decoded bytes.
///
/// Example:
/// ```dart
/// final decoded = b64d('SGVsbG8gV29ybGQ');
/// print(decoded); // Prints: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100]
/// ```
Uint8List b64d(String b64) => base64Url.decode(padBase64(b64));

/// Encodes a byte list into Base64 URL encoding, stripping any trailing '='.
///
/// Parameters:
/// - [bytes]: The list of bytes to encode.
///
/// Returns a Base64 URL encoded string without padding.
///
/// Example:
/// ```dart
/// final encoded = b64e([72, 101, 108, 108, 111]);
/// print(encoded); // Prints: SGVsbG8
/// ```
String b64e(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

/// Checks if a hexadecimal string has the '0x' prefix.
///
/// Parameters:
/// - [value]: The string to check.
///
/// Returns true if the string is a valid hex string with '0x' prefix, false otherwise.
///
/// Example:
/// ```dart
/// print(hexHasPrefix('0x1234')); // Prints: true
/// print(hexHasPrefix('1234')); // Prints: false
/// ```
bool hexHasPrefix(String value) {
  return isHex(value, ignoreLength: true) && value.substring(0, 2) == '0x';
}

/// Strips the '0x' prefix from a hexadecimal string if present.
///
/// Parameters:
/// - [value]: The hexadecimal string.
///
/// Returns the hexadecimal string without the '0x' prefix.
/// Throws an exception if the input is not a valid hexadecimal string.
///
/// Example:
/// ```dart
/// print(hexStripPrefix('0x1234')); // Prints: 1234
/// print(hexStripPrefix('1234')); // Prints: 1234
/// ```
String hexStripPrefix(String value) {
  if (value.isEmpty) {
    return '';
  }
  if (hexHasPrefix(value)) {
    return value.substring(2);
  }
  final reg = RegExp(r'^[a-fA-F\d]+$');
  if (reg.hasMatch(value)) {
    return value;
  }
  throw Exception("unable to reach prefix");
}

/// Checks if a value is a valid hexadecimal string.
///
/// Parameters:
/// - [value]: The value to check.
/// - [bits]: Optional bit length to validate against. Defaults to -1 (no length check).
/// - [ignoreLength]: If true, ignores odd-length strings. Defaults to false.
///
/// Returns true if the value is a valid hexadecimal string, false otherwise.
///
/// Example:
/// ```dart
/// print(isHex('0x1234')); // Prints: true
/// print(isHex('0x123')); // Prints: false
/// print(isHex('0x123', ignoreLength: true)); // Prints: true
/// ```
bool isHex(dynamic value, {int bits = -1, bool ignoreLength = false}) {
  if (value is! String) {
    return false;
  }
  if (value == '0x') {
    // Adapt Ethereum special cases.
    return true;
  }
  if (value.startsWith('0x')) {
    value = value.substring(2);
  }
  if (_hexadecimal.hasMatch(value)) {
    if (bits != -1) {
      return value.length == (bits / 4).ceil();
    }
    return ignoreLength || value.length % 2 == 0;
  }
  return false;
}

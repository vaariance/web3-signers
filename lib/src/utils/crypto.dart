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
/// print(components); // Output: ['01', '02']
/// ```
Future<Tuple<Uint256, Uint256>> getPublicKeyFromBytes(
    Uint8List publicKeyBytes) async {
  final pKey =
      await EcdsaPublicKey.importSpkiKey(publicKeyBytes, EllipticCurve.p256);
  final jwk = await pKey.exportJsonWebKey();
  if (jwk.containsKey('x') && jwk.containsKey('y')) {
    final x = base64Url.normalize(jwk['x']);
    final y = base64Url.normalize(jwk['y']);

    final decodedX = hexlify(base64Url.decode(x));
    final decodedY = hexlify(base64Url.decode(y));

    return Tuple(Uint256.fromHex(decodedX), Uint256.fromHex(decodedY));
  } else {
    throw "Invalid public key";
  }
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
  ASN1Parser parser = ASN1Parser(signatureBytes);
  ASN1Sequence parsedSignature = parser.nextObject() as ASN1Sequence;
  ASN1Integer rValue = parsedSignature.elements[0] as ASN1Integer;
  ASN1Integer sValue = parsedSignature.elements[1] as ASN1Integer;
  Uint8List rBytes = rValue.valueBytes();
  Uint8List sBytes = sValue.valueBytes();

  if (shouldRemoveLeadingZero(rBytes)) {
    rBytes = rBytes.sublist(1);
  }
  if (shouldRemoveLeadingZero(sBytes)) {
    sBytes = sBytes.sublist(1);
  }

  final r = hexlify(rBytes);
  final s = hexlify(sBytes);
  return Tuple(Uint256.fromHex(r), Uint256.fromHex(s));
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
/// print(hexString); // Output: '0x01ff'
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
/// print("Value is valid: $value");
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
/// print("SHA-256 Hash: ${hash.toString()}");
/// ```
List<int> sha256Hash(List<int> input) {
  final algo = const DartSha256();
  final sink = algo.newHashSink();
  sink.add(input);
  sink.close();
  final hash = sink.hashSync();
  return hash.bytes;
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
/// print("Remove Leading Zero: $removeZero");
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
/// print("Combined List: $combinedList");
/// ```
List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}

String padBase64(String b64) {
  final padding = 4 - b64.length % 4;
  return padding < 4 ? '$b64${"=" * padding}' : b64;
}

/// Decode a Base64 URL encoded string adding in any required '='
Uint8List b64d(String b64) => base64Url.decode(padBase64(b64));

/// Encode a byte list into Base64 URL encoding, stripping any trailing '='
String b64e(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

bool hexHasPrefix(String value) {
  return isHex(value, ignoreLength: true) && value.substring(0, 2) == '0x';
}

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

/// [value] should be `0x` hex string.
Uint8List hexToU8a(String value, [int bitLength = -1]) {
  if (!isHex(value)) {
    throw ArgumentError.value(value, 'value', 'Not a valid hex string');
  }
  final newValue = hexStripPrefix(value);
  final valLength = newValue.length / 2;
  final bufLength = (bitLength == -1 ? valLength : bitLength / 8).ceil();
  final result = Uint8List(bufLength);
  final offset = max(0, bufLength - valLength).toInt();
  for (int index = 0; index < bufLength - offset; index++) {
    final subStart = index * 2;
    final subEnd =
        subStart + 2 <= newValue.length ? subStart + 2 : newValue.length;
    final arrIndex = index + offset;
    result[arrIndex] = int.parse(
      newValue.substring(subStart, subEnd),
      radix: 16,
    );
  }
  return result;
}

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

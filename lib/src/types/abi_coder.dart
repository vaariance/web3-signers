part of '../../web3_signers.dart';

@Deprecated("abi has been renamed to Abi")
// ignore: camel_case_types
typedef abi = Abi;

/// Interface class for handling Ethereum's Application Binary Interface (ABI).
///
/// The ABI is a data encoding scheme used in Ethereum for ABI encoding
/// and interaction with contracts within Ethereum.
interface class Abi {
  Abi._();

  /// Decodes a list of ABI-encoded types and values.
  ///
  /// Parameters:
  ///   - `types`: A list of string types describing the ABI types to decode.
  ///   - `value`: A [Bytes] containing the ABI-encoded data to be decoded.
  ///
  /// Returns:
  ///   A list of decoded values with the specified type.
  ///
  /// Example:
  /// ```dart
  /// var decodedValues = abi.decode(['uint256', 'string'], encodedData);
  /// ```
  static List decode(List<String> types, Bytes value) {
    return eip712.decode(types, value);
  }

  /// Encodes a list of types and values into ABI-encoded data.
  ///
  /// Parameters:
  ///   - `types`: A list of string types describing the ABI types.
  ///   - `values`: A list of dynamic values to be ABI-encoded.
  ///
  /// Returns:
  ///   A [Bytes] containing the ABI-encoded types and values.
  ///
  /// Example:
  /// ```dart
  /// var encodedData = abi.encode(['uint256', 'string'], [BigInt.from(123), 'Hello']);
  /// ```
  static Bytes encode(List<String> types, List<dynamic> values) {
    return eip712.encode(types, values);
  }

  /// Packs a list of heterogeneous values into a single [Bytes] array.
  ///
  /// This method does not perform any form of sanity check. hence, all inputs
  ///
  /// Parameters:
  ///   - `values`: A list of values to pack.
  ///
  /// Returns:
  ///   A single [Bytes] instance containing the concatenated byte
  ///   representation of every supplied value.
  ///
  /// Example:
  /// ```dart
  /// final packed = Abi.pack([
  ///   BigInt.from(0x42),
  ///   '0xdeadbeef',
  ///   utf8.encode('hello'),
  /// ]);
  /// ```
  static Bytes pack(List<dynamic> values) {
    final list = <int>[];

    for (var item in values) {
      if (item is BigInt) {
        list.addAll(intToBytes(item));
      } else if (item is Bytes) {
        list.addAll(item);
      } else if (item is String) {
        eip712.isHex(item)
            ? list.addAll(hexToBytes(item))
            : list.addAll(utf8.encode(item));
      } else if (item is num) {
        list.addAll(intToBytes(BigInt.from(item)));
      } else if (item is List) {
        list.addAll(pack(item));
      } else {
        throw ArgumentError(
          "Unable to pack provided value. Invalid Type",
          item.toString(),
        );
      }
    }

    return Bytes.fromList(list);
  }
}

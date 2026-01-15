part of '../../web3_signers.dart';

/// Decodes a list of ABI-encoded types and values.
///
/// Parameters:
///   - `types`: a list of [AbiParameter] or [String] types or [Map]s describing the ABI types to decode.
///   - `value`: A [Bytes] containing the ABI-encoded data to be decoded.
///
/// Returns:
///   A list of decoded values with the specified type.
///
/// Example:
/// ```dart
/// var decodedValues = decodeAbiParameters(['uint256', 'string'], encodedData);
/// ```
List decodeAbiParameters(List<dynamic> types, Bytes value) {
  final parsedTypes =
      types.map((t) {
        if (t is String) return t;
        if (t is AbiParameter) return t.canonicalType;
        if (t is Dict) return AbiParameter.fromJson(t).canonicalType;
        throw ArgumentError('Invalid type: $t');
      }).toList();
  return decode(parsedTypes, value);
}

/// Encodes a list of types and values into ABI-encoded data.
///
/// Parameters:
///   - `types`: a list of [AbiParameter] or [String] types or [Map]s describing the ABI types.
///   - `values`: A list of dynamic values to be ABI-encoded.
///
/// Returns:
///   A [Bytes] containing the ABI-encoded types and values.
///
/// Example:
/// ```dart
/// var encodedData = encodeAbiParameters(['uint256', 'string'], [BigInt.from(123), 'Hello']);
/// ```
Bytes encodeAbiParameters(List<dynamic> types, List<dynamic> values) {
  final parsedTypes =
      types.map((t) {
        if (t is String) return t;
        if (t is AbiParameter) return t.canonicalType;
        if (t is Dict) return AbiParameter.fromJson(t).canonicalType;
        throw ArgumentError('Invalid type: $t');
      }).toList();
  return encode(parsedTypes, values);
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
/// final packed = encodePacked([
///   BigInt.from(0x42),
///   '0xdeadbeef',
///   utf8.encode('hello'),
/// ]);
/// ```
Bytes encodePacked(List<dynamic> values) {
  final list = <int>[];

  for (var item in values) {
    if (item is BigInt) {
      list.addAll(intToBytes(item));
    } else if (item is Bytes) {
      list.addAll(item);
    } else if (item is String) {
      isHex(item)
          ? list.addAll(hexToBytes(item))
          : list.addAll(utf8.encode(item));
    } else if (item is num) {
      list.addAll(intToBytes(BigInt.from(item)));
    } else if (item is List) {
      list.addAll(encodePacked(item));
    } else if (item is _Uint) {
      list.addAll(item.toBytes());
    } else {
      throw ArgumentError(
        "Unable to pack provided value. Invalid Type",
        item.toString(),
      );
    }
  }

  return Bytes.fromList(list);
}

/// Searches for an ABI item in a list of parsed items.
///
/// Parameters:
///   - `abi`: A list of [AbiItem]s to search through.
///   - `name`: The name of the function or event to find.
///   - `args`: Optional list of arguments to match the input length.
///
/// Returns:
///   The matching [AbiItem], or `null` if no match is found.
///
/// Example:
/// ```dart
/// final output = getAbiItem(abi: uniswapAbi, name: 'swapExactInputForOutput');
/// ```
AbiItem? getAbiItem({
  required List<dynamic> abi,
  String? name,
  List<dynamic>? args,
}) {
  for (final item in abi) {
    if (item is AbiItem) {
      if (name != null && item.name != name) continue;
      if (args != null && item.inputs.length != args.length) continue;
      return item;
    } else if (item is Map) {
      if (name != null && item['name'] != name) continue;
      final inputs = item['inputs'] as List?;
      if (args != null && (inputs?.length ?? 0) != args.length) continue;
      return AbiItem.fromJson(Map<String, dynamic>.from(item));
    }
  }
  return null;
}

/// Parses a list of human-readable ABI signatures into a list of [AbiItem]s.
///
/// Parameters:
///   - `sources`: A list of human-readable ABI signature strings.
///
/// Returns:
///   A list of [AbiItem] objects representing the parsed signatures.
///
/// Example:
/// ```dart
/// final abi = parseAbi([
///   'function balanceOf(address owner) view returns (uint256)',
///   'event Transfer(address indexed from, address indexed to, uint256 amount)',
/// ]);
/// ```
List<AbiItem> parseAbi(List<String> sources) {
  return sources.map((s) => parseAbiItem(s)).toList();
}

/// Parses a generic signature (function, event, error) into an [AbiItem].
///
/// Parameters:
///   - `source`: A human-readable ABI signature string.
///
/// Returns:
///   An [AbiItem] object representing the parsed signature.
///
/// Example:
/// ```dart
/// final item = parseAbiItem('function foo(uint a) view returns (uint b)');
/// ```
AbiItem parseAbiItem(String source) {
  source = source.trim();

  String itemType = _extractItemType(source);
  String cleanSource = _extractCleanSource(source);

  final firstParen = cleanSource.indexOf('(');
  if (firstParen == -1) {
    throw FormatException(
      'Invalid signature: expected arguments in parentheses',
    );
  }

  final name = cleanSource.substring(0, firstParen).trim();
  final inputsEnd = _findInputsEnd(cleanSource, firstParen);

  final inputsString = cleanSource.substring(firstParen + 1, inputsEnd);
  final inputs = parseAbiParameters(inputsString);

  String remainder = cleanSource.substring(inputsEnd + 1).trim();
  String modifiersPart = remainder;
  void updateModifierPart(String part) {
    modifiersPart = part;
  }

  final outputs = _extractOutputs(remainder, itemType, updateModifierPart);

  String stateMutability = switch (modifiersPart) {
    _ when modifiersPart.contains('view') => 'view',
    _ when modifiersPart.contains('pure') => 'pure',
    _ when modifiersPart.contains('payable') => 'payable',
    _ => 'nonpayable',
  };

  if (itemType == 'event' || itemType == 'error') {
    stateMutability = 'view';
  }

  return AbiItem(
    name: name.isEmpty ? null : name,
    type: itemType,
    inputs: inputs,
    outputs: outputs,
    stateMutability: stateMutability,
  );
}

/// Parses a single ABI parameter string.
///
/// Supports:
/// - Basic types: `uint256`, `address`, `string`, etc.
/// - Tuples: `tuple(uint a, uint b)`, `(uint a, uint b)`
/// - Arrays: `uint256[]`, `tuple(...)[]`
///
/// Parameters:
///   - `source`: A string representing a single ABI parameter.
///
/// Returns:
///   An [AbiParameter] object.
///
/// Example:
/// ```dart
/// final param = parseAbiParameter('uint256 amount');
/// ```
AbiParameter parseAbiParameter(String source) {
  source = source.trim();

  String type;
  String? name;
  List<AbiParameter>? components;

  if (source.startsWith('tuple') || source.startsWith('(')) {
    final startParen = source.indexOf('(');
    final closingParen = _extractClosingParen(startParen, source);

    final innerContent = source.substring(startParen + 1, closingParen);
    components = parseAbiParameters(innerContent);

    // Get the part after the closing parenthesis: e.g., "[] points" or " points"
    String afterType = source.substring(closingParen + 1).trim();

    type = _extractType(afterType);
    name = _extractName(afterType);
  } else {
    // Standard types
    final parts = source.split(RegExp(r'\s+'));
    final validParts =
        parts
            .where((p) => !['calldata', 'memory', 'storage'].contains(p))
            .toList();

    if (validParts.isEmpty) {
      throw FormatException('Invalid Abi Parameter: $source');
    }

    type = validParts[0];

    if (validParts.length > 1) {
      if (validParts[1] == 'indexed') {
        if (validParts.length > 2) name = validParts[2];
      } else {
        name = validParts[1];
      }
    }
  }

  return AbiParameter(name: name, type: type, components: components);
}

/// Parses a list of ABI parameters from a string representation.
///
/// Handles nested tuples and standard ABI types.
///
/// Parameters:
///   - `source`: A string containing comma-separated ABI parameters.
///
/// Returns:
///   A list of [AbiParameter] objects.
///
/// Example:
/// ```dart
/// final params = parseAbiParameters('uint256 amount, (string name, address wallet) user');
/// ```
List<AbiParameter> parseAbiParameters(String source) {
  if (source.trim().isEmpty) return [];
  if (source.trim() == '()') return [];

  // Handle surrounding parentheses if present (common in full usage)
  if (source.trim().startsWith('(') && source.trim().endsWith(')')) {
    source = source.trim().substring(1, source.trim().length - 1);
  }

  final parameters = <AbiParameter>[];
  final parts = _splitParams(source);

  for (final part in parts) {
    parameters.add(parseAbiParameter(part));
  }

  return parameters;
}

String _extractCleanSource(String source) {
  return switch (source) {
    _ when source.startsWith('function ') => source.substring(9).trim(),
    _ when source.startsWith('event ') => source.substring(6).trim(),
    _ when source.startsWith('error ') => source.substring(6).trim(),
    _ when source.startsWith('constructor') => source.substring(11).trim(),
    _ when source.startsWith('fallback') => source.substring(8).trim(),
    _ when source.startsWith('receive') => source.substring(7).trim(),
    _ => source,
  };
}

// Find the closing paren that matches this startParen
int _extractClosingParen(int startParen, String source) {
  int depth = 0;
  int closingParen = -1;
  for (int i = startParen; i < source.length; i++) {
    if (source[i] == '(') {
      depth++;
    } else if (source[i] == ')') {
      depth--;
    }

    if (depth == 0) {
      closingParen = i;
      break;
    }
  }

  if (closingParen == -1) {
    throw FormatException('Unbalanced parentheses in parameter: $source');
  }

  return closingParen;
}

String _extractItemType(String source) {
  return switch (source) {
    _ when source.startsWith('event ') => 'event',
    _ when source.startsWith('error ') => 'error',
    _ when source.startsWith('constructor') => 'constructor',
    _ when source.startsWith('fallback') => 'fallback',
    _ when source.startsWith('receive') => 'receive',
    _ => 'function',
  };
}

List<AbiParameter> _extractOutputs(
  String remainder,
  String itemType,
  Function(String) updateModifierPart,
) {
  List<AbiParameter> outputs = [];

  final returnsIndex = remainder.indexOf('returns');
  if (returnsIndex != -1) {
    updateModifierPart(remainder.substring(0, returnsIndex).trim());

    final afterReturns = remainder.substring(returnsIndex + 7).trim();
    if (afterReturns.startsWith('(') && afterReturns.endsWith(')')) {
      final outputInner = afterReturns.substring(1, afterReturns.length - 1);
      outputs = parseAbiParameters(outputInner);
    }
  }
  return outputs;
}

int _findInputsEnd(String cleanSource, int firstParen) {
  int depth = 0;
  int inputsEnd = -1;
  for (int i = firstParen; i < cleanSource.length; i++) {
    if (cleanSource[i] == '(') {
      depth++;
    } else if (cleanSource[i] == ')') {
      depth--;
    }

    if (depth == 0) {
      inputsEnd = i;
      break;
    }
  }
  return inputsEnd;
}

/// Helper to split comma-separated params ignoring nested parens
List<String> _splitParams(String text) {
  final res = <String>[];
  int depth = 0;
  int lastIndex = 0;

  for (int i = 0; i < text.length; i++) {
    if (text[i] == '(') {
      depth++;
    } else if (text[i] == ')') {
      depth--;
    } else if (text[i] == ',' && depth == 0) {
      res.add(text.substring(lastIndex, i).trim());
      lastIndex = i + 1;
    }
  }
  if (lastIndex < text.length) {
    res.add(text.substring(lastIndex).trim());
  }
  return res.where((s) => s.isNotEmpty).toList();
}

String _extractType(String afterType) {
  String type;
  if (afterType.startsWith('[')) {
    final arrayMatch = RegExp(r'^(\[[0-9]*\])+').firstMatch(afterType);
    if (arrayMatch != null) {
      type = 'tuple${arrayMatch.group(0)}';
    } else {
      type = 'tuple';
    }
  } else {
    type = 'tuple';
  }
  return type;
}

String? _extractName(String afterType) {
  // Strip array suffix if present to find the name
  if (afterType.startsWith('[')) {
    final arrayMatch = RegExp(r'^(\[[0-9]*\])+').firstMatch(afterType);
    if (arrayMatch != null) {
      afterType = afterType.substring(arrayMatch.group(0)!.length).trim();
    }
  }

  String? name = afterType.isEmpty ? null : afterType;
  if (name != null) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1 && nameParts[0] == 'indexed') {
      name = nameParts.last;
    } else if (nameParts.length == 1 && nameParts[0] == 'indexed') {
      name = null;
    }
  }
  return name;
}

part of '../../web3_signers.dart';

typedef Dict = Map<String, dynamic>;

/// Represents a parameter in an ABI definition.
class AbiParameter {
  /// The name of the parameter.
  final String? name;

  /// The canonical type of the parameter (e.g., 'uint256', 'address', 'tuple').
  final String type;

  /// For tuple types, the nested parameters that make up the tuple.
  final List<AbiParameter>? components;

  /// The original type name from Solidity, if applicable (e.g., 'struct MyStruct').
  final String? internalType;

  const AbiParameter({
    this.name,
    required this.type,
    this.components,
    this.internalType,
  });

  Dict toJson() {
    return {
      if (name != null) 'name': name,
      'type': type,
      if (components != null)
        'components': components!.map((c) => c.toJson()).toList(),
      if (internalType != null) 'internalType': internalType,
    };
  }

  factory AbiParameter.fromJson(Dict json) {
    return AbiParameter(
      name: json['name'] as String?,
      type: json['type'] as String,
      components:
          (json['components'] as List<Dict>?)
              ?.map((e) => AbiParameter.fromJson(e))
              .toList(),
      internalType: json['internalType'] as String?,
    );
  }

  /// Returns the canonical type string for this parameter.
  ///
  /// For tuples, this includes the types of all components recursively.
  String get canonicalType {
    if (components == null || components!.isEmpty) {
      return type;
    }

    final arraySuffix = type.startsWith('tuple') ? type.substring(5) : '';
    final componentTypes = components!.map((c) => c.canonicalType).join(',');
    return 'tuple($componentTypes)$arraySuffix';
  }

  @override
  String toString() =>
      'AbiParameter(name: $name, type: $type, components: $components)';
}

/// Represents a function, event, or error definition in the ABI.
class AbiItem {
  final String? name;
  final String type;
  final List<AbiParameter> inputs;
  final List<AbiParameter> outputs;
  final String stateMutability;

  const AbiItem({
    this.name,
    required this.type,
    this.inputs = const [],
    this.outputs = const [],
    this.stateMutability = 'nonpayable',
  });

  Dict toJson() {
    return {
      'type': type,
      if (name != null) 'name': name,
      'inputs': inputs.map((i) => i.toJson()).toList(),
      'outputs': outputs.map((o) => o.toJson()).toList(),
      'stateMutability': stateMutability,
    };
  }

  factory AbiItem.fromJson(Dict json) {
    return AbiItem(
      name: json['name'] as String?,
      type: json['type'] as String? ?? 'function',
      inputs:
          (json['inputs'] as List?)
              ?.map((e) => AbiParameter.fromJson(e as Dict))
              .toList() ??
          const [],
      outputs:
          (json['outputs'] as List?)
              ?.map((e) => AbiParameter.fromJson(e as Dict))
              .toList() ??
          const [],
      stateMutability: json['stateMutability'] as String? ?? 'nonpayable',
    );
  }

  @override
  String toString() =>
      'AbiItem(name: $name, type: $type, inputs: $inputs, outputs: $outputs, state: $stateMutability)';
}

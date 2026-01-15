# ABI Utilities

The `web3_signers` package provides a robust set of utilities for working with Ethereum ABIs, compatible with [viem.sh](https://viem.sh) standards. 

It supports **human-readable ABI parsing**, **encoding/decoding**, and **recursive tuple structures**.

## key Differences from Solidity/Viem
> [!NOTE]  
> **Tuples**: In this library, structs are represented strictly as **inline tuples** (e.g. `tuple(string name, uint256 age)`). We **do not** use a separate `struct` definition registry. If you have a Solidity struct, convert it to its tuple representation for parsing.

## API Reference

### `parseAbi`

Parses a list of human-readable ABI strings (functions, events, errors) into structured `AbiItem` objects.

```dart
import 'package:web3_signers/web3_signers.dart';

final abi = parseAbi([
  'function balanceOf(address owner) view returns (uint256)',
  'event Transfer(address indexed from, address indexed to, uint256 amount)',
  'error InsufficientFunds(uint256 available)',
]);
```

### `parseAbiParameters`

Parses human-readable ABI parameters into a `AbiParameter`(s) object. Supports deep nesting.

```dart
// Simple
final param = parseAbiParameters('address from, address to, uint256 amount');

// Nested Tuple (single)
final tuple = parseAbiParameter('tuple(string name, (uint x, uint y) point) user');
```

### `encodeAbiParameters`

Encodes values according to the provided types. Supports **Flexible Inputs**: strings, `AbiParameter` objects, or raw Maps.

```dart
// 1. Using Standard ABI Strings
final encoded = encodeAbiParameters(
  ['uint256', 'string'], 
  [BigInt.from(420), 'Hello']
);

// 2. Using Parsed Parameters
final params = parseAbiParameters('address from, address to, uint256 amount');
final encodedTuple = encodeAbiParameters(
  params, 
  ["0x0bj", "0xAda", BigInt.two]
);

// 3. Using Raw Maps (JSON ABI style)
final encodedMap = encodeAbiParameters(
  [{'type': 'string', 'name': 'message'}], 
  ['Variance']
);
```

### `decodeAbiParameters`

Decodes binary data into a list of values. Supports the same **Flexible Inputs** as encoding.

```dart
final types = ['uint256', 'address'];
final decoded = decodeAbiParameters(types, encodedData);

print(decoded[0]); // BigInt
print(decoded[1]); // EthereumAddress (Bytes)
```

## Advanced Usage

### Deeply Nested Tuples
The parser handles arbitrary nesting levels seamlessly.

```dart
// A function taking a list of complex user structs
final source = 'function updateUsers(tuple(string name, tuple(uint256[] scores) stats)[] users)';
final item = parseAbiItem(source);

// Verify structure
print(item.inputs[0].type); // tuple[]
print(item.inputs[0].components![1].name); // stats
```

### Manual ABI Item Construction
You can also construct `AbiItem` and `AbiParameter` manually if preferred.

```dart
final item = AbiItem(
  type: 'function',
  name: 'transfer',
  inputs: [AbiParameter(type: 'address', name: 'to'), AbiParameter(type: 'uint256', name: 'amount')],
  outputs: [AbiParameter(type: 'bool')],
);
```

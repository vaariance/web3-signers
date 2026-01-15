import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  group('Abi Parsing', () {
    test('Encodes and decodes native types', () {
      final types = ['uint256', 'bytes20', 'bool'];
      final values = [
        BigInt.from(123),
        hexToBytes('0x1234567890123456789012345678901234567890'),
        true,
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0], equals(values[0]));
      // Address decoded usually normalized to checksum or lower case depending on impl
      // Assuming it returns EthereumAddress or string. Let's check consistency.
      expect(
        bytesToHex(decoded[1]).toLowerCase(),
        equals(bytesToHex(values[1] as Bytes).toLowerCase()),
      );
      expect(decoded[2], equals(values[2]));
    });

    test('Encodes and decodes dynamic types (string, bytes)', () {
      final types = ['string', 'bytes'];
      final values = [
        'Hello World',
        Bytes.fromList([0x01, 0x02, 0x03]),
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0], equals(values[0]));
      expect(decoded[1], equals(values[1]));
    });

    test('Encodes and decodes arrays', () {
      final types = ['uint256[]', 'bool[2]'];
      final values = [
        [BigInt.from(1), BigInt.from(2), BigInt.from(3)],
        [true, false],
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0], equals(values[0]));
      expect(decoded[1], equals(values[1]));
    });

    test('Encodes and decodes tuples', () {
      final types = ['(uint256,string)'];
      final values = [
        [BigInt.from(42), 'Variance'],
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0][0], equals(values[0][0]));
      expect(decoded[0][1], equals(values[0][1]));
    });

    test('Encodes and decodes tuple arrays', () {
      final types = ['(uint256,uint256)[]'];
      final values = [
        [
          [BigInt.from(1), BigInt.from(2)],
          [BigInt.from(3), BigInt.from(4)],
        ],
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0].length, equals(2));
      expect(decoded[0][0][0], equals(BigInt.from(1)));
      expect(decoded[0][0][1], equals(BigInt.from(2)));
      expect(decoded[0][1][0], equals(BigInt.from(3)));
      expect(decoded[0][1][1], equals(BigInt.from(4)));
    });

    test('Encodes and decodes complex nested structures', () {
      // (string, uint256[])
      final types = ['(string,uint256[])'];
      final values = [
        [
          'Test',
          [BigInt.one, BigInt.two],
        ],
      ];

      final encoded = encodeAbiParameters(types, values);
      final decoded = decodeAbiParameters(types, encoded);

      expect(decoded[0][0], equals('Test'));
      expect(decoded[0][1], equals([BigInt.one, BigInt.two]));
    });

    group('pack', () {
      test('packs various types into bytes', () {
        final packed = encodePacked([
          BigInt.from(0x42),
          Bytes.fromList([0x12, 0x34]),
          '0xabcd', // hex string
          'hello', // utf8 string
          123, // num (int)
          Uint8.max, // uint
          [1, 2, 3], // list
        ]);

        // BigInt(0x42) -> 0x42 (variable length or packed minimal?
        // intToBytes usually produces minimal bytes. 0x42 is 1 byte.
        // 0x1234 -> 2 bytes
        // 0xabcd (hex string) -> 2 bytes [0xab, 0xcd]
        // 'hello' -> 5 bytes
        // 123 -> 0x7b (1 byte)
        // uint8 -> 1 byte
        // [1, 2, 3] -> 3 bytes
        expect(packed, isA<Bytes>());
        expect(packed.length, greaterThan(0));
        expect(packed.length, equals(15));
      });

      test('packs nested lists', () {
        final packed = encodePacked([
          [0x01, 0x02],
          [0x03],
        ]);
        expect(packed, equals(Bytes.fromList([0x01, 0x02, 0x03])));
      });
      test('throws error if any invalid type is provided', () {
        expect(
          () => encodePacked([(data: BigInt.from(0x42)), 'hello']),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'message',
              contains('Unable to pack provided value. Invalid Type'),
            ),
          ),
        );
      });
    });

    group('parseAbiParameter', () {
      test('parses simple type', () {
        final param = parseAbiParameter('uint256');
        expect(param.type, 'uint256');
        expect(param.name, null);
        expect(param.components, null);
      });

      test('parses type with name', () {
        final param = parseAbiParameter('address owner');
        expect(param.type, 'address');
        expect(param.name, 'owner');
      });

      test('parses type with name and extra spaces', () {
        final param = parseAbiParameter('  string   name  ');
        expect(param.type, 'string');
        expect(param.name, 'name');
      });

      test('parses explicit tuple', () {
        final param = parseAbiParameter('tuple(uint256 a, uint256 b) point');
        expect(param.type, 'tuple');
        expect(param.name, 'point');
        expect(param.components, hasLength(2));
        expect(param.components![0].type, 'uint256');
        expect(param.components![0].name, 'a');
        expect(param.components![1].name, 'b');
      });

      test('parses implicit tuple (parentheses only)', () {
        final param = parseAbiParameter('(string key, bytes value) data');
        expect(param.type, 'tuple');
        expect(param.name, 'data');
        expect(param.components, hasLength(2));
        expect(param.components![0].type, 'string');
      });

      test('parses array of tuples', () {
        final param = parseAbiParameter('tuple(uint x, uint y)[] points');
        expect(param.type, 'tuple[]');
        expect(param.name, 'points');
        expect(param.components, hasLength(2));
      });

      test('parses implicit tuple array', () {
        final param = parseAbiParameter('(uint x, uint y)[] points');
        expect(param.type, 'tuple[]');
        expect(param.components, hasLength(2));
      });

      test('parses nested tuples', () {
        final param = parseAbiParameter(
          'tuple(string id, (uint256 x, uint256 y) info) user',
        );
        expect(param.type, 'tuple');
        expect(param.components, hasLength(2));
        expect(param.components![0].name, 'id');
        expect(param.components![1].name, 'info');
        expect(param.components![1].type, 'tuple');
        expect(param.components![1].components, hasLength(2));
      });

      test('parses indexed parameters', () {
        final param = parseAbiParameter('address indexed from');
        expect(param.type, 'address');
        expect(param.name, 'from');
        // We don't store 'indexed' in AbiParameter currently but ensuring it parses correctly is key
      });
    });

    group('parseAbiItem', () {
      test('parses simple function', () {
        final item = parseAbiItem('function foo(uint256 a) returns (bool)');
        expect(item.type, 'function');
        expect(item.name, 'foo');
        expect(item.inputs, hasLength(1));
        expect(item.inputs[0].name, 'a');
        expect(item.outputs, hasLength(1));
        expect(item.outputs[0].type, 'bool');
        expect(item.stateMutability, 'nonpayable');
      });

      test('parses function with modifiers', () {
        final item = parseAbiItem(
          'function bar(address a) view returns (uint256)',
        );
        expect(item.name, 'bar');
        expect(item.stateMutability, 'view');
      });

      test('parses pure function', () {
        final item = parseAbiItem('function baz() pure');
        expect(item.stateMutability, 'pure');
        expect(item.inputs, isEmpty);
        expect(item.outputs, isEmpty);
      });

      test('parses payable function', () {
        final item = parseAbiItem('function pay() payable');
        expect(item.stateMutability, 'payable');
      });

      test('parses event', () {
        final item = parseAbiItem(
          'event Transfer(address indexed from, address indexed to, uint256 value)',
        );
        expect(item.type, 'event');
        expect(item.name, 'Transfer');
        expect(item.inputs, hasLength(3));
        expect(item.inputs[0].name, 'from');
        // expect(item.inputs[0].indexed, true); // if we added indexed field
      });

      test('parses error', () {
        final item = parseAbiItem('error InvalidToken(address token)');
        expect(item.type, 'error');
        expect(item.name, 'InvalidToken');
      });

      test('parses fallback', () {
        // fallback() external payable
        // fallback implies no name usually, inputs might be empty
        final item = parseAbiItem('fallback() payable');
        expect(item.type, 'fallback');
        expect(item.name, null);
      });

      test('parses deeply nested structure in function', () {
        final item = parseAbiItem('function update((string a, uint b)[] data)');
        expect(item.inputs, hasLength(1));
        expect(item.inputs[0].type, 'tuple[]');
        expect(item.inputs[0].components, hasLength(2));
      });

      test('parses incredible deeply nested structure', () {
        // defined: native type, list of native types, list of tuple which contains tuple which contains list of native types
        final source =
            'function incredible(uint256 a, uint256[] b, tuple(string x, tuple(bool[] flags) inner)[] complex)';
        final item = parseAbiItem(source);

        expect(item.name, 'incredible');
        expect(item.inputs, hasLength(3));

        // 1. native type
        expect(item.inputs[0].type, 'uint256');
        expect(item.inputs[0].name, 'a');

        // 2. list of native types
        expect(item.inputs[1].type, 'uint256[]');
        expect(item.inputs[1].name, 'b');

        // 3. list of tuple
        final complex = item.inputs[2];
        expect(complex.type, 'tuple[]');
        expect(complex.name, 'complex');
        expect(complex.components, hasLength(2));

        // which tuple contains ... string x
        expect(complex.components![0].type, 'string');
        expect(complex.components![0].name, 'x');

        // ... and another tuple 'inner'
        final inner = complex.components![1];
        expect(inner.type, 'tuple');
        expect(inner.name, 'inner');
        expect(inner.components, hasLength(1));

        // ... which contains list of native types 'flags'
        final flags = inner.components![0];
        expect(flags.type, 'bool[]');
        expect(flags.name, 'flags');
      });
    });

    group('parseAbi', () {
      test('parses multiple items', () {
        final abi = parseAbi([
          'function foo(uint a)',
          'event Bar(uint b)',
          'error Baz()',
        ]);
        expect(abi, hasLength(3));
        expect(abi[0].type, 'function');
        expect(abi[1].type, 'event');
        expect(abi[2].type, 'error');
      });
    });

    group('getAbiItem', () {
      final abi = parseAbi([
        'function foo(uint a)',
        'function foo(uint a, uint b)',
        'function bar()',
      ]);

      test('finds by name', () {
        final item = getAbiItem(abi: abi, name: 'bar');
        expect(item, isNotNull);
        expect(item!.name, 'bar');
      });

      test('finds by json', () {
        final item = getAbiItem(
          abi: [
            {
              'name': 'bar',
              'type': 'function',
              'inputs': [
                {'type': 'uint256'},
              ],
              'outputs': [],
              'stateMutability': 'view',
            },
          ],
          name: 'bar',
        );
        expect(item, isNotNull);
        expect(item!.name, 'bar');
      });

      test('finds overload by args length', () {
        final item1 = getAbiItem(abi: abi, name: 'foo', args: [1]); // 1 arg
        expect(item1, isNotNull);
        expect(item1!.inputs, hasLength(1));

        final item2 = getAbiItem(abi: abi, name: 'foo', args: [1, 2]); // 2 args
        expect(item2, isNotNull);
        expect(item2!.inputs, hasLength(2));
      });

      test('returns null if not found', () {
        expect(getAbiItem(abi: abi, name: 'missing'), isNull);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final item = parseAbiItem(
          'function foo(uint256 a) view returns (bool success)',
        );
        final json = item.toJson();

        expect(json['type'], 'function');
        expect(json['name'], 'foo');
        expect(json['stateMutability'], 'view');
        expect(json['inputs'], isA<List>());
        expect((json['inputs'] as List).first['name'], 'a');
        expect((json['inputs'] as List).first['type'], 'uint256');
        expect(json['outputs'], isA<List>());
      });
    });
    group('Flexible Inputs', () {
      test('AbiParameter.fromJson parsing', () {
        final json = {
          'name': 'user',
          'type': 'tuple',
          'components': [
            {'name': 'age', 'type': 'uint256'},
            {'name': 'name', 'type': 'string'},
          ],
        };
        final param = AbiParameter.fromJson(json);
        expect(param.name, 'user');
        expect(param.type, 'tuple');
        expect(param.components, hasLength(2));
        expect(param.components![0].name, 'age');
      });

      test('canonicalType generates correct string', () {
        final param = AbiParameter(
          type: 'tuple',
          components: [
            AbiParameter(type: 'uint256'),
            AbiParameter(type: 'address'),
          ],
        );
        expect(param.canonicalType, 'tuple(uint256,address)');
      });

      test('canonicalType recursive', () {
        final param = AbiParameter(
          type: 'tuple[]',
          components: [
            AbiParameter(type: 'uint256'),
            AbiParameter(
              type: 'tuple',
              components: [AbiParameter(type: 'bool')],
            ),
          ],
        );
        expect(param.canonicalType, 'tuple(uint256,tuple(bool))[]');
      });

      test('encodeAbiParameters supports mixed inputs', () {
        // Case A: AbiParameter
        final param = parseAbiParameter('uint256');
        // Case B: Map
        final mapParam = {'type': 'string'};

        final encoded = encodeAbiParameters(
          [param, mapParam, 'bool'],
          [BigInt.one, 'hello', true],
        );

        final decoded = decodeAbiParameters([param, mapParam, 'bool'], encoded);

        expect(decoded[0], BigInt.one);
        expect(decoded[1], 'hello');
        expect(decoded[2], true);
      });

      test('throws on invalid input type', () {
        expect(
          () => encodeAbiParameters([123], [1]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('AbiItem.fromJson parsing', () {
        final json = {
          'name': 'transfer',
          'type': 'function',
          'stateMutability': 'payable',
          'inputs': [
            {'name': 'to', 'type': 'address'},
          ],
          'outputs': [
            {'type': 'bool'},
          ],
        };
        final item = AbiItem.fromJson(json);
        expect(item.name, 'transfer');
        expect(item.type, 'function');
        expect(item.stateMutability, 'payable');
        expect(item.inputs, hasLength(1));
        expect(item.inputs[0].name, 'to');
        expect(item.outputs, hasLength(1));
      });
    });
  });
}

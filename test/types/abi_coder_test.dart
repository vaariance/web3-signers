import 'package:eip7702/eip7702.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  group('Abi Coder', () {
    test('Encodes and decodes native types', () {
      final types = ['uint256', 'address', 'bool'];
      final values = [
        BigInt.from(123),
        toEthAddress('0x1234567890123456789012345678901234567890'),
        true,
      ];

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

      expect(decoded[0], equals(values[0]));
      // Address decoded usually normalized to checksum or lower case depending on impl
      // Assuming it returns EthereumAddress or string. Let's check consistency.
      expect(
        decoded[1].toString().toLowerCase(),
        equals(values[1].toString().toLowerCase()),
      );
      expect(decoded[2], equals(values[2]));
    });

    test('Encodes and decodes dynamic types (string, bytes)', () {
      final types = ['string', 'bytes'];
      final values = [
        'Hello World',
        Bytes.fromList([0x01, 0x02, 0x03]),
      ];

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

      expect(decoded[0], equals(values[0]));
      expect(decoded[1], equals(values[1]));
    });

    test('Encodes and decodes arrays', () {
      final types = ['uint256[]', 'bool[2]'];
      final values = [
        [BigInt.from(1), BigInt.from(2), BigInt.from(3)],
        [true, false],
      ];

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

      expect(decoded[0], equals(values[0]));
      expect(decoded[1], equals(values[1]));
    });

    test('Encodes and decodes tuples', () {
      final types = ['(uint256,string)'];
      final values = [
        [BigInt.from(42), 'Variance'],
      ];

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

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

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

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

      final encoded = Abi.encode(types, values);
      final decoded = Abi.decode(types, encoded);

      expect(decoded[0][0], equals('Test'));
      expect(decoded[0][1], equals([BigInt.one, BigInt.two]));
    });

    group('Abi.pack', () {
      test('packs various types into bytes', () {
        final packed = Abi.pack([
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
        final packed = Abi.pack([
          [0x01, 0x02],
          [0x03],
        ]);
        expect(packed, equals(Bytes.fromList([0x01, 0x02, 0x03])));
      });
      test('throws error if any invalid type is provided', () {
        expect(
          () => Abi.pack([(data: BigInt.from(0x42)), 'hello']),
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
  });
}

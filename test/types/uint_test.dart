import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';

class _UintTester {
  final String name;
  final int bits;
  final Function(BigInt) constructor;
  final Function(String) fromHex;
  final Function(Bytes) fromBytes;
  final dynamic zero;
  final dynamic max;

  _UintTester({
    required this.name,
    required this.bits,
    required this.constructor,
    required this.fromHex,
    required this.fromBytes,
    required this.zero,
    required this.max,
  });
}

void main() {
  final testers = <_UintTester>[
    _UintTester(
      name: 'Uint8',
      bits: 8,
      constructor: (v) => Uint8(v),
      fromHex: (s) => Uint8.fromHex(s),
      fromBytes: (b) => Uint8.fromBytes(b),
      zero: Uint8.zero,
      max: Uint8.max,
    ),
    _UintTester(
      name: 'Uint16',
      bits: 16,
      constructor: (v) => Uint16(v),
      fromHex: (s) => Uint16.fromHex(s),
      fromBytes: (b) => Uint16.fromBytes(b),
      zero: Uint16.zero,
      max: Uint16.max,
    ),
    _UintTester(
      name: 'Uint24',
      bits: 24,
      constructor: (v) => Uint24(v),
      fromHex: (s) => Uint24.fromHex(s),
      fromBytes: (b) => Uint24.fromBytes(b),
      zero: Uint24.zero,
      max: Uint24.max,
    ),
    _UintTester(
      name: 'Uint32',
      bits: 32,
      constructor: (v) => Uint32(v),
      fromHex: (s) => Uint32.fromHex(s),
      fromBytes: (b) => Uint32.fromBytes(b),
      zero: Uint32.zero,
      max: Uint32.max,
    ),
    _UintTester(
      name: 'Uint40',
      bits: 40,
      constructor: (v) => Uint40(v),
      fromHex: (s) => Uint40.fromHex(s),
      fromBytes: (b) => Uint40.fromBytes(b),
      zero: Uint40.zero,
      max: Uint40.max,
    ),
    _UintTester(
      name: 'Uint48',
      bits: 48,
      constructor: (v) => Uint48(v),
      fromHex: (s) => Uint48.fromHex(s),
      fromBytes: (b) => Uint48.fromBytes(b),
      zero: Uint48.zero,
      max: Uint48.max,
    ),
    _UintTester(
      name: 'Uint56',
      bits: 56,
      constructor: (v) => Uint56(v),
      fromHex: (s) => Uint56.fromHex(s),
      fromBytes: (b) => Uint56.fromBytes(b),
      zero: Uint56.zero,
      max: Uint56.max,
    ),
    _UintTester(
      name: 'Uint64',
      bits: 64,
      constructor: (v) => Uint64(v),
      fromHex: (s) => Uint64.fromHex(s),
      fromBytes: (b) => Uint64.fromBytes(b),
      zero: Uint64.zero,
      max: Uint64.max,
    ),
    _UintTester(
      name: 'Uint72',
      bits: 72,
      constructor: (v) => Uint72(v),
      fromHex: (s) => Uint72.fromHex(s),
      fromBytes: (b) => Uint72.fromBytes(b),
      zero: Uint72.zero,
      max: Uint72.max,
    ),
    _UintTester(
      name: 'Uint80',
      bits: 80,
      constructor: (v) => Uint80(v),
      fromHex: (s) => Uint80.fromHex(s),
      fromBytes: (b) => Uint80.fromBytes(b),
      zero: Uint80.zero,
      max: Uint80.max,
    ),
    _UintTester(
      name: 'Uint88',
      bits: 88,
      constructor: (v) => Uint88(v),
      fromHex: (s) => Uint88.fromHex(s),
      fromBytes: (b) => Uint88.fromBytes(b),
      zero: Uint88.zero,
      max: Uint88.max,
    ),
    _UintTester(
      name: 'Uint96',
      bits: 96,
      constructor: (v) => Uint96(v),
      fromHex: (s) => Uint96.fromHex(s),
      fromBytes: (b) => Uint96.fromBytes(b),
      zero: Uint96.zero,
      max: Uint96.max,
    ),
    _UintTester(
      name: 'Uint104',
      bits: 104,
      constructor: (v) => Uint104(v),
      fromHex: (s) => Uint104.fromHex(s),
      fromBytes: (b) => Uint104.fromBytes(b),
      zero: Uint104.zero,
      max: Uint104.max,
    ),
    _UintTester(
      name: 'Uint112',
      bits: 112,
      constructor: (v) => Uint112(v),
      fromHex: (s) => Uint112.fromHex(s),
      fromBytes: (b) => Uint112.fromBytes(b),
      zero: Uint112.zero,
      max: Uint112.max,
    ),
    _UintTester(
      name: 'Uint120',
      bits: 120,
      constructor: (v) => Uint120(v),
      fromHex: (s) => Uint120.fromHex(s),
      fromBytes: (b) => Uint120.fromBytes(b),
      zero: Uint120.zero,
      max: Uint120.max,
    ),
    _UintTester(
      name: 'Uint128',
      bits: 128,
      constructor: (v) => Uint128(v),
      fromHex: (s) => Uint128.fromHex(s),
      fromBytes: (b) => Uint128.fromBytes(b),
      zero: Uint128.zero,
      max: Uint128.max,
    ),
    _UintTester(
      name: 'Uint136',
      bits: 136,
      constructor: (v) => Uint136(v),
      fromHex: (s) => Uint136.fromHex(s),
      fromBytes: (b) => Uint136.fromBytes(b),
      zero: Uint136.zero,
      max: Uint136.max,
    ),
    _UintTester(
      name: 'Uint144',
      bits: 144,
      constructor: (v) => Uint144(v),
      fromHex: (s) => Uint144.fromHex(s),
      fromBytes: (b) => Uint144.fromBytes(b),
      zero: Uint144.zero,
      max: Uint144.max,
    ),
    _UintTester(
      name: 'Uint152',
      bits: 152,
      constructor: (v) => Uint152(v),
      fromHex: (s) => Uint152.fromHex(s),
      fromBytes: (b) => Uint152.fromBytes(b),
      zero: Uint152.zero,
      max: Uint152.max,
    ),
    _UintTester(
      name: 'Uint160',
      bits: 160,
      constructor: (v) => Uint160(v),
      fromHex: (s) => Uint160.fromHex(s),
      fromBytes: (b) => Uint160.fromBytes(b),
      zero: Uint160.zero,
      max: Uint160.max,
    ),
    _UintTester(
      name: 'Uint168',
      bits: 168,
      constructor: (v) => Uint168(v),
      fromHex: (s) => Uint168.fromHex(s),
      fromBytes: (b) => Uint168.fromBytes(b),
      zero: Uint168.zero,
      max: Uint168.max,
    ),
    _UintTester(
      name: 'Uint176',
      bits: 176,
      constructor: (v) => Uint176(v),
      fromHex: (s) => Uint176.fromHex(s),
      fromBytes: (b) => Uint176.fromBytes(b),
      zero: Uint176.zero,
      max: Uint176.max,
    ),
    _UintTester(
      name: 'Uint184',
      bits: 184,
      constructor: (v) => Uint184(v),
      fromHex: (s) => Uint184.fromHex(s),
      fromBytes: (b) => Uint184.fromBytes(b),
      zero: Uint184.zero,
      max: Uint184.max,
    ),
    _UintTester(
      name: 'Uint192',
      bits: 192,
      constructor: (v) => Uint192(v),
      fromHex: (s) => Uint192.fromHex(s),
      fromBytes: (b) => Uint192.fromBytes(b),
      zero: Uint192.zero,
      max: Uint192.max,
    ),
    _UintTester(
      name: 'Uint200',
      bits: 200,
      constructor: (v) => Uint200(v),
      fromHex: (s) => Uint200.fromHex(s),
      fromBytes: (b) => Uint200.fromBytes(b),
      zero: Uint200.zero,
      max: Uint200.max,
    ),
    _UintTester(
      name: 'Uint208',
      bits: 208,
      constructor: (v) => Uint208(v),
      fromHex: (s) => Uint208.fromHex(s),
      fromBytes: (b) => Uint208.fromBytes(b),
      zero: Uint208.zero,
      max: Uint208.max,
    ),
    _UintTester(
      name: 'Uint216',
      bits: 216,
      constructor: (v) => Uint216(v),
      fromHex: (s) => Uint216.fromHex(s),
      fromBytes: (b) => Uint216.fromBytes(b),
      zero: Uint216.zero,
      max: Uint216.max,
    ),
    _UintTester(
      name: 'Uint224',
      bits: 224,
      constructor: (v) => Uint224(v),
      fromHex: (s) => Uint224.fromHex(s),
      fromBytes: (b) => Uint224.fromBytes(b),
      zero: Uint224.zero,
      max: Uint224.max,
    ),
    _UintTester(
      name: 'Uint232',
      bits: 232,
      constructor: (v) => Uint232(v),
      fromHex: (s) => Uint232.fromHex(s),
      fromBytes: (b) => Uint232.fromBytes(b),
      zero: Uint232.zero,
      max: Uint232.max,
    ),
    _UintTester(
      name: 'Uint240',
      bits: 240,
      constructor: (v) => Uint240(v),
      fromHex: (s) => Uint240.fromHex(s),
      fromBytes: (b) => Uint240.fromBytes(b),
      zero: Uint240.zero,
      max: Uint240.max,
    ),
    _UintTester(
      name: 'Uint248',
      bits: 248,
      constructor: (v) => Uint248(v),
      fromHex: (s) => Uint248.fromHex(s),
      fromBytes: (b) => Uint248.fromBytes(b),
      zero: Uint248.zero,
      max: Uint248.max,
    ),
    _UintTester(
      name: 'Uint256',
      bits: 256,
      constructor: (v) => Uint256(v),
      fromHex: (s) => Uint256.fromHex(s),
      fromBytes: (b) => Uint256.fromBytes(b),
      zero: Uint256.zero,
      max: Uint256.max,
    ),
  ];

  group('Uint Tests', () {
    for (final t in testers) {
      group(t.name, () {
        test('Constants', () {
          expect(t.zero.value, BigInt.zero);
          final expectedMax = (BigInt.one << t.bits) - BigInt.one;
          expect(t.max.value, expectedMax);
          expect(t.max.bitWidth, t.bits);
        });

        test('Validation', () {
          final max = (BigInt.one << t.bits) - BigInt.one;
          expect(t.constructor(BigInt.zero).value, BigInt.zero);
          expect(t.constructor(max).value, max);

          expect(() => t.constructor(BigInt.from(-1)), throwsArgumentError);
          expect(() => t.constructor(max + BigInt.one), throwsArgumentError);
        });

        test('Factories & Conversions', () {
          // Hex roundtrip
          final value = BigInt.one;
          final u = t.constructor(value);
          final hex = u.toHex();
          expect(hex.startsWith('0x'), isTrue);

          // Reconstruct
          final u2 = t.fromHex(hex);
          expect(u2.value, value);
          expect(u2, equals(u));

          // Bytes roundtrip
          final bytes = u.toBytes();
          final u3 = t.fromBytes(bytes);
          expect(u3.value, value);
        });

        test('Operations', () {
          // Basic arithmetic
          final two = t.constructor(BigInt.two);
          final one = t.constructor(BigInt.one);

          expect((two + one).value, BigInt.from(3));
          expect((two - one).value, BigInt.one);
          expect((two * one).value, BigInt.two);
          expect((two / one).value, BigInt.two);

          // Overflow behavior (wraparound via & _maxValue in _Uint implementation)
          // (max + 1) should be 0 safely if the implementation does wrapping additions.
          // Let's check _Uint impl in uint.dart.
          // Line 685: _Uint operator +(_Uint other) => _create((_value + other._value) & _maxValue);
          // It clearly wraps.

          final max = t.max;
          expect((max + one).value, BigInt.zero);

          // Underflow
          // (0 - 1) & max => max
          final zero = t.zero;
          expect((zero - one).value, max.value);
        });
      });
    }
  });
}

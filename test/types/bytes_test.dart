import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  group('Bytes Extension Tests', () {
    test('eq returns true for identical bytes', () {
      final list1 = Bytes.fromList([1, 2, 3]);
      final list2 = Bytes.fromList([1, 2, 3]);
      expect(list1.eq(list2), isTrue);
    });

    test('eq returns false for different bytes', () {
      final list1 = Bytes.fromList([1, 2, 3]);
      final list2 = Bytes.fromList([1, 2, 4]);
      expect(list1.eq(list2), isFalse);
    });

    test('concat combining two lists correctly', () {
      final list1 = Bytes.fromList([1, 2]);
      final list2 = Bytes.fromList([3, 4]);
      final result = list1.concat(list2);
      expect(result, equals(Bytes.fromList([1, 2, 3, 4])));
    });

    test('padLeft adds leading zeros up to n bytes', () {
      final list = Bytes.fromList([1, 2, 3]);
      final padded = list.padLeft(5);
      expect(padded, equals(Bytes.fromList([0, 0, 1, 2, 3])));
    });

    test('padLeft returns original list if n is equal to list length', () {
      final list = Bytes.fromList([1, 2, 3]);
      expect(list.padLeft(3), equals(list));
    });

    test('padLeft throws if length exceeds n', () {
      final list = Bytes.fromList([1, 2, 3]);
      expect(() => list.padLeft(2), throwsArgumentError);
    });

    test('padRight adds trailing zeros up to n bytes', () {
      final list = Bytes.fromList([1, 2, 3]);
      final padded = list.padRight(5);
      expect(padded, equals(Bytes.fromList([1, 2, 3, 0, 0])));
    });

    test('padRight returns original list if n is equal to list length', () {
      final list = Bytes.fromList([1, 2, 3]);
      expect(list.padRight(3), equals(list));
    });

    test('padRight throws if length exceeds n', () {
      final list = Bytes.fromList([1, 2, 3]);
      expect(() => list.padRight(2), throwsArgumentError);
    });

    test('toHex returns correct hex string', () {
      final list = Bytes.fromList([1, 15, 255]);
      expect(list.toHex(), equals("0x010fff"));
    });

    test('let applies function correctly', () {
      final list = Bytes.fromList([1, 2, 3]);
      final sum = list.let((it) => it.reduce((a, b) => a + b));
      expect(sum, equals(6));
    });

    group('Bytes typedef usage', () {
      test('can be instantiated as Uint8List', () {
        final b = Bytes(10);
        expect(b, isA<Uint8List>());
        expect(b.length, 10);
      });
    });
  });
}

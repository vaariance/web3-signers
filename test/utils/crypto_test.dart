import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  group('Crypto Utils', () {
    test('getRandomValues returns correct length and range', () {
      final bytes = getRandomValues(16);
      expect(bytes.length, equals(16));
      expect(bytes.every((b) => b >= 0 && b <= 255), isTrue);
    });

    test('hexlify converts bytes to hex string', () {
      expect(hexlify([0, 1, 15, 255]), equals("0x00010fff"));
      expect(hexlify([]), equals("0x"));
    });

    test('sha256Hash computes correct hash', () {
      final input = utf8.encode("Hello World");
      final hash = sha256Hash(input);
      // SHA256("Hello World") = a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
      expect(
        hexlify(hash),
        equals(
          "0xa591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
        ),
      );
    });

    test('b64e and b64d encode and decode correctly', () {
      final input = utf8.encode("Hello World");
      final encoded = b64e(input);
      // "SGVsbG8gV29ybGQ" (Base64Url no padding)
      expect(encoded, equals("SGVsbG8gV29ybGQ"));

      final decoded = b64d(encoded);
      expect(decoded, equals(input));
    });

    test('b64d handles padding correctly', () {
      // "Hello" -> "SGVsbG8=" -> "SGVsbG8" no padding
      const input = "SGVsbG8";
      final decoded = b64d(input);
      expect(utf8.decode(decoded), equals("Hello"));
    });

    test(
      'shouldRemoveLeadingZero correctly identifies negative ECDSA integers',
      () {
        // 0x0080 -> remove 00 because 80 has MSB set
        expect(shouldRemoveLeadingZero(Bytes.fromList([0x00, 0x80])), isTrue);
        // 0x007f -> do NOT remove 00, 7f is positive
        expect(shouldRemoveLeadingZero(Bytes.fromList([0x00, 0x7f])), isFalse);
        // 0x80 -> undefined/false (length check?) function assumes bytes is at least 2?
        // The function is: bytes[0] == 0 && (bytes[1] & 0x80) != 0.
        expect(shouldRemoveLeadingZero(Bytes.fromList([0x01, 0x80])), isFalse);
      },
    );

    test('getMessagingSignature parses DER signature', () {
      // 30 44 02 20 [r] 02 20 [s]
      // r = 1, s = 2
      final r = BigInt.one;
      final s = BigInt.two;

      List<int> toDerInteger(BigInt i) {
        var hex = i.toRadixString(16);
        if (hex.length % 2 != 0) hex = '0$hex';
        var bytes = List<int>.generate(
          hex.length ~/ 2,
          (j) => int.parse(hex.substring(j * 2, j * 2 + 2), radix: 16),
        );
        if (bytes[0] & 0x80 != 0) bytes = [0x00, ...bytes];
        return [0x02, bytes.length, ...bytes];
      }

      final content = [...toDerInteger(r), ...toDerInteger(s)];
      final der = Uint8List.fromList([0x30, content.length, ...content]);

      final sig = getMessagingSignature(Bytes.fromList(der));
      expect(sig.r, equals(Uint256(r)));
      expect(sig.s, equals(Uint256(s)));
    });
  });
}

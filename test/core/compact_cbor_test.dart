import 'package:web3_signers/web3_signers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CBOR Extraction', () {
    test('extractAuthData extracts correct bytes', () {
      final authData = Bytes.fromList(List.generate(10, (i) => i));
      final attestationObject = Bytes.fromList([
        0xa2, // Map(2)
        0x63, 0x66, 0x6d, 0x74, // "fmt"
        0x64, 0x6e, 0x6f, 0x6e, 0x65, // "none"
        0x68, 0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61, // "authData"
        0x4a, // Byte String length 10
        ...authData, // The data
      ]);

      final extracted = extractCBORPattern(attestationObject);
      expect(extracted, isNotNull);
      expect(extracted, equals(authData));
    });

    test('extractCBORPattern handles long authData (0x58 extension)', () {
      // 32 bytes authData
      final authData = Bytes.fromList(List.generate(32, (i) => i));

      final attestationObject = Bytes.fromList([
        0xa1, // Map(1)
        0x68, 0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61, // "authData"
        0x58, 0x20, // Byte String (0x58), length 32 (0x20)
        ...authData,
      ]);

      final extracted = extractCBORPattern(attestationObject);
      expect(extracted, isNotNull);
      expect(extracted, equals(authData));
    });

    test('extractCBORPattern handles 2-byte length extension (0x59)', () {
      // 300 bytes authData (requires 2 bytes length: > 255)
      final length = 300;
      final authData = Bytes.fromList(List.generate(length, (i) => i % 256));

      final attestationObject = Bytes.fromList([
        0xa1, // Map(1)
        0x68, 0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61, // "authData"
        0x59, // 2-byte extension header
        (length >> 8) & 0xFF, length & 0xFF, // Length 300 (0x012C)
        ...authData,
      ]);

      final extracted = extractCBORPattern(attestationObject);
      expect(extracted, isNotNull);
      expect(extracted!.length, equals(length));
      expect(extracted, equals(authData));
    });

    test('extractCBORPattern handles 4-byte length extension (0x5A)', () {
      // 70000 bytes authData (requires 4 bytes length: > 65535)
      // Note: 70KB is large for a test but manageable.
      final length = 70000;
      final authData = Bytes.fromList(List.generate(length, (i) => i % 256));

      final attestationObject = Bytes.fromList([
        0xa1, // Map(1)
        0x68, 0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61, // "authData"
        0x5A, // 4-byte extension header
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
        ...authData,
      ]);

      final extracted = extractCBORPattern(attestationObject);
      expect(extracted, isNotNull);
      expect(extracted!.length, equals(length));
      expect(extracted, equals(authData));
    });

    test('extractXYFromCoseKey extracts coordinates', () {
      // COSE Key
      // Map(?)
      // ...
      // -2 (0x21): x_bytes (32)
      // -3 (0x22): y_bytes (32)

      final xBytes = Bytes.fromList(List.filled(32, 1));
      final yBytes = Bytes.fromList(List.filled(32, 2));

      final pubKey = Bytes.fromList([
        0xa5, // Map(5)
        0x01, 0x02, // Key 1: 2 (EC2)
        0x20, 0x01, // Key -1: 1 (P-256)
        // Key -2: xBytes
        0x21,
        0x58, 0x20, // Byte String, len 32
        ...xBytes,
        // Key -3: yBytes
        0x22,
        0x58, 0x20,
        ...yBytes,
        0x03, 0x04, // dummy: 4
      ]);

      final result = extractXYFromCoseKey(pubKey);
      expect(result, isNotNull);
      expect(result?.$1.toBytes(), equals(xBytes));
      expect(result?.$2.toBytes(), equals(yBytes));
    });

    test('extractXYFromCoseKey returns null if keys missing', () {
      final pubKey = Bytes.fromList([
        0xa1,
        0x21, 0x41, 0x00, // Key -2, value bytes len 1.
      ]);
      final result = extractXYFromCoseKey(pubKey);
      expect(result, isNull);
    });
  });
}

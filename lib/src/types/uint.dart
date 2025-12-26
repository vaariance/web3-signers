part of '../../web3_signers.dart';

// ============================================================================
// Uint8 - 8-bit unsigned integer (0 to 255)
// ============================================================================

class Uint8 extends _Uint {
  Uint8(super._value);

  static Uint8 get zero => Uint8(BigInt.zero);
  static Uint8 get max => Uint8((BigInt.one << 8) - BigInt.one);

  factory Uint8.fromHex(String hex) => Uint8(hexToInt(hex));
  factory Uint8.fromBytes(Bytes bytes) => Uint8(bytesToUnsignedInt(bytes));

  @override
  Uint8 _create(BigInt value) => Uint8(value);

  @override
  int get bitWidth => 8;
}

// ============================================================================
// Uint16 - 16-bit unsigned integer (0 to 65535)
// ============================================================================

class Uint16 extends _Uint {
  Uint16(super._value);

  static Uint16 get zero => Uint16(BigInt.zero);
  static Uint16 get max => Uint16((BigInt.one << 16) - BigInt.one);

  factory Uint16.fromHex(String hex) => Uint16(hexToInt(hex));
  factory Uint16.fromBytes(Bytes bytes) => Uint16(bytesToUnsignedInt(bytes));

  @override
  Uint16 _create(BigInt value) => Uint16(value);

  @override
  int get bitWidth => 16;
}

// ============================================================================
// Uint24 - 24-bit unsigned integer
// ============================================================================

class Uint24 extends _Uint {
  Uint24(super._value);

  static Uint24 get zero => Uint24(BigInt.zero);
  static Uint24 get max => Uint24((BigInt.one << 24) - BigInt.one);

  factory Uint24.fromHex(String hex) => Uint24(hexToInt(hex));
  factory Uint24.fromBytes(Bytes bytes) => Uint24(bytesToUnsignedInt(bytes));

  @override
  Uint24 _create(BigInt value) => Uint24(value);

  @override
  int get bitWidth => 24;
}

// ============================================================================
// Uint32 - 32-bit unsigned integer (0 to 4294967295)
// ============================================================================

class Uint32 extends _Uint {
  Uint32(super._value);

  static Uint32 get zero => Uint32(BigInt.zero);
  static Uint32 get max => Uint32((BigInt.one << 32) - BigInt.one);

  factory Uint32.fromHex(String hex) => Uint32(hexToInt(hex));
  factory Uint32.fromBytes(Bytes bytes) => Uint32(bytesToUnsignedInt(bytes));

  @override
  Uint32 _create(BigInt value) => Uint32(value);

  @override
  int get bitWidth => 32;
}

// ============================================================================
// Uint40 - 40-bit unsigned integer
// ============================================================================

class Uint40 extends _Uint {
  Uint40(super._value);

  static Uint40 get zero => Uint40(BigInt.zero);
  static Uint40 get max => Uint40((BigInt.one << 40) - BigInt.one);

  factory Uint40.fromHex(String hex) => Uint40(hexToInt(hex));
  factory Uint40.fromBytes(Bytes bytes) => Uint40(bytesToUnsignedInt(bytes));

  @override
  Uint40 _create(BigInt value) => Uint40(value);

  @override
  int get bitWidth => 40;
}

// ============================================================================
// Uint48 - 48-bit unsigned integer
// ============================================================================

class Uint48 extends _Uint {
  Uint48(super._value);

  static Uint48 get zero => Uint48(BigInt.zero);
  static Uint48 get max => Uint48((BigInt.one << 48) - BigInt.one);

  factory Uint48.fromHex(String hex) => Uint48(hexToInt(hex));
  factory Uint48.fromBytes(Bytes bytes) => Uint48(bytesToUnsignedInt(bytes));

  @override
  Uint48 _create(BigInt value) => Uint48(value);

  @override
  int get bitWidth => 48;
}

// ============================================================================
// Uint56 - 56-bit unsigned integer
// ============================================================================

class Uint56 extends _Uint {
  Uint56(super._value);

  static Uint56 get zero => Uint56(BigInt.zero);
  static Uint56 get max => Uint56((BigInt.one << 56) - BigInt.one);

  factory Uint56.fromHex(String hex) => Uint56(hexToInt(hex));
  factory Uint56.fromBytes(Bytes bytes) => Uint56(bytesToUnsignedInt(bytes));

  @override
  Uint56 _create(BigInt value) => Uint56(value);

  @override
  int get bitWidth => 56;
}

// ============================================================================
// Uint64 - 64-bit unsigned integer (0 to 18446744073709551615)
// ============================================================================

class Uint64 extends _Uint {
  Uint64(super._value);

  static Uint64 get zero => Uint64(BigInt.zero);
  static Uint64 get max => Uint64((BigInt.one << 64) - BigInt.one);

  factory Uint64.fromHex(String hex) => Uint64(hexToInt(hex));
  factory Uint64.fromBytes(Bytes bytes) => Uint64(bytesToUnsignedInt(bytes));

  @override
  Uint64 _create(BigInt value) => Uint64(value);

  @override
  int get bitWidth => 64;
}

// ============================================================================
// Uint72 - 72-bit unsigned integer
// ============================================================================

class Uint72 extends _Uint {
  Uint72(super._value);

  static Uint72 get zero => Uint72(BigInt.zero);
  static Uint72 get max => Uint72((BigInt.one << 72) - BigInt.one);

  factory Uint72.fromHex(String hex) => Uint72(hexToInt(hex));
  factory Uint72.fromBytes(Bytes bytes) => Uint72(bytesToUnsignedInt(bytes));

  @override
  Uint72 _create(BigInt value) => Uint72(value);

  @override
  int get bitWidth => 72;
}

// ============================================================================
// Uint80 - 80-bit unsigned integer
// ============================================================================

class Uint80 extends _Uint {
  Uint80(super._value);

  static Uint80 get zero => Uint80(BigInt.zero);
  static Uint80 get max => Uint80((BigInt.one << 80) - BigInt.one);

  factory Uint80.fromHex(String hex) => Uint80(hexToInt(hex));
  factory Uint80.fromBytes(Bytes bytes) => Uint80(bytesToUnsignedInt(bytes));

  @override
  Uint80 _create(BigInt value) => Uint80(value);

  @override
  int get bitWidth => 80;
}

// ============================================================================
// Uint88 - 88-bit unsigned integer
// ============================================================================

class Uint88 extends _Uint {
  Uint88(super._value);

  static Uint88 get zero => Uint88(BigInt.zero);
  static Uint88 get max => Uint88((BigInt.one << 88) - BigInt.one);

  factory Uint88.fromHex(String hex) => Uint88(hexToInt(hex));
  factory Uint88.fromBytes(Bytes bytes) => Uint88(bytesToUnsignedInt(bytes));

  @override
  Uint88 _create(BigInt value) => Uint88(value);

  @override
  int get bitWidth => 88;
}

// ============================================================================
// Uint96 - 96-bit unsigned integer
// ============================================================================

class Uint96 extends _Uint {
  Uint96(super._value);

  static Uint96 get zero => Uint96(BigInt.zero);
  static Uint96 get max => Uint96((BigInt.one << 96) - BigInt.one);

  factory Uint96.fromHex(String hex) => Uint96(hexToInt(hex));
  factory Uint96.fromBytes(Bytes bytes) => Uint96(bytesToUnsignedInt(bytes));

  @override
  Uint96 _create(BigInt value) => Uint96(value);

  @override
  int get bitWidth => 96;
}

// ============================================================================
// Uint104 - 104-bit unsigned integer
// ============================================================================

class Uint104 extends _Uint {
  Uint104(super._value);

  static Uint104 get zero => Uint104(BigInt.zero);
  static Uint104 get max => Uint104((BigInt.one << 104) - BigInt.one);

  factory Uint104.fromHex(String hex) => Uint104(hexToInt(hex));
  factory Uint104.fromBytes(Bytes bytes) => Uint104(bytesToUnsignedInt(bytes));

  @override
  Uint104 _create(BigInt value) => Uint104(value);

  @override
  int get bitWidth => 104;
}

// ============================================================================
// Uint112 - 112-bit unsigned integer
// ============================================================================

class Uint112 extends _Uint {
  Uint112(super._value);

  static Uint112 get zero => Uint112(BigInt.zero);
  static Uint112 get max => Uint112((BigInt.one << 112) - BigInt.one);

  factory Uint112.fromHex(String hex) => Uint112(hexToInt(hex));
  factory Uint112.fromBytes(Bytes bytes) => Uint112(bytesToUnsignedInt(bytes));

  @override
  Uint112 _create(BigInt value) => Uint112(value);

  @override
  int get bitWidth => 112;
}

// ============================================================================
// Uint120 - 120-bit unsigned integer
// ============================================================================

class Uint120 extends _Uint {
  Uint120(super._value);

  static Uint120 get zero => Uint120(BigInt.zero);
  static Uint120 get max => Uint120((BigInt.one << 120) - BigInt.one);

  factory Uint120.fromHex(String hex) => Uint120(hexToInt(hex));
  factory Uint120.fromBytes(Bytes bytes) => Uint120(bytesToUnsignedInt(bytes));

  @override
  Uint120 _create(BigInt value) => Uint120(value);

  @override
  int get bitWidth => 120;
}

// ============================================================================
// Uint128 - 128-bit unsigned integer
// ============================================================================

class Uint128 extends _Uint {
  Uint128(super._value);

  static Uint128 get zero => Uint128(BigInt.zero);
  static Uint128 get max => Uint128((BigInt.one << 128) - BigInt.one);

  factory Uint128.fromHex(String hex) => Uint128(hexToInt(hex));
  factory Uint128.fromBytes(Bytes bytes) => Uint128(bytesToUnsignedInt(bytes));

  @override
  Uint128 _create(BigInt value) => Uint128(value);

  @override
  int get bitWidth => 128;
}

// ============================================================================
// Uint136 - 136-bit unsigned integer
// ============================================================================

class Uint136 extends _Uint {
  Uint136(super._value);

  static Uint136 get zero => Uint136(BigInt.zero);
  static Uint136 get max => Uint136((BigInt.one << 136) - BigInt.one);

  factory Uint136.fromHex(String hex) => Uint136(hexToInt(hex));
  factory Uint136.fromBytes(Bytes bytes) => Uint136(bytesToUnsignedInt(bytes));

  @override
  Uint136 _create(BigInt value) => Uint136(value);

  @override
  int get bitWidth => 136;
}

// ============================================================================
// Uint144 - 144-bit unsigned integer
// ============================================================================

class Uint144 extends _Uint {
  Uint144(super._value);

  static Uint144 get zero => Uint144(BigInt.zero);
  static Uint144 get max => Uint144((BigInt.one << 144) - BigInt.one);

  factory Uint144.fromHex(String hex) => Uint144(hexToInt(hex));
  factory Uint144.fromBytes(Bytes bytes) => Uint144(bytesToUnsignedInt(bytes));

  @override
  Uint144 _create(BigInt value) => Uint144(value);

  @override
  int get bitWidth => 144;
}

// ============================================================================
// Uint152 - 152-bit unsigned integer
// ============================================================================

class Uint152 extends _Uint {
  Uint152(super._value);

  static Uint152 get zero => Uint152(BigInt.zero);
  static Uint152 get max => Uint152((BigInt.one << 152) - BigInt.one);

  factory Uint152.fromHex(String hex) => Uint152(hexToInt(hex));
  factory Uint152.fromBytes(Bytes bytes) => Uint152(bytesToUnsignedInt(bytes));

  @override
  Uint152 _create(BigInt value) => Uint152(value);

  @override
  int get bitWidth => 152;
}

// ============================================================================
// Uint160 - 160-bit unsigned integer
// ============================================================================

class Uint160 extends _Uint {
  Uint160(super._value);

  static Uint160 get zero => Uint160(BigInt.zero);
  static Uint160 get max => Uint160((BigInt.one << 160) - BigInt.one);

  factory Uint160.fromHex(String hex) => Uint160(hexToInt(hex));
  factory Uint160.fromBytes(Bytes bytes) => Uint160(bytesToUnsignedInt(bytes));

  @override
  Uint160 _create(BigInt value) => Uint160(value);

  @override
  int get bitWidth => 160;
}

// ============================================================================
// Uint168 - 168-bit unsigned integer
// ============================================================================

class Uint168 extends _Uint {
  Uint168(super._value);

  static Uint168 get zero => Uint168(BigInt.zero);
  static Uint168 get max => Uint168((BigInt.one << 168) - BigInt.one);

  factory Uint168.fromHex(String hex) => Uint168(hexToInt(hex));
  factory Uint168.fromBytes(Bytes bytes) => Uint168(bytesToUnsignedInt(bytes));

  @override
  Uint168 _create(BigInt value) => Uint168(value);

  @override
  int get bitWidth => 168;
}

// ============================================================================
// Uint176 - 176-bit unsigned integer
// ============================================================================

class Uint176 extends _Uint {
  Uint176(super._value);

  static Uint176 get zero => Uint176(BigInt.zero);
  static Uint176 get max => Uint176((BigInt.one << 176) - BigInt.one);

  factory Uint176.fromHex(String hex) => Uint176(hexToInt(hex));
  factory Uint176.fromBytes(Bytes bytes) => Uint176(bytesToUnsignedInt(bytes));

  @override
  Uint176 _create(BigInt value) => Uint176(value);

  @override
  int get bitWidth => 176;
}

// ============================================================================
// Uint184 - 184-bit unsigned integer
// ============================================================================

class Uint184 extends _Uint {
  Uint184(super._value);

  static Uint184 get zero => Uint184(BigInt.zero);
  static Uint184 get max => Uint184((BigInt.one << 184) - BigInt.one);

  factory Uint184.fromHex(String hex) => Uint184(hexToInt(hex));
  factory Uint184.fromBytes(Bytes bytes) => Uint184(bytesToUnsignedInt(bytes));

  @override
  Uint184 _create(BigInt value) => Uint184(value);

  @override
  int get bitWidth => 184;
}

// ============================================================================
// Uint192 - 192-bit unsigned integer
// ============================================================================

class Uint192 extends _Uint {
  Uint192(super._value);

  static Uint192 get zero => Uint192(BigInt.zero);
  static Uint192 get max => Uint192((BigInt.one << 192) - BigInt.one);

  factory Uint192.fromHex(String hex) => Uint192(hexToInt(hex));
  factory Uint192.fromBytes(Bytes bytes) => Uint192(bytesToUnsignedInt(bytes));

  @override
  Uint192 _create(BigInt value) => Uint192(value);

  @override
  int get bitWidth => 192;
}

// ============================================================================
// Uint200 - 200-bit unsigned integer
// ============================================================================

class Uint200 extends _Uint {
  Uint200(super._value);

  static Uint200 get zero => Uint200(BigInt.zero);
  static Uint200 get max => Uint200((BigInt.one << 200) - BigInt.one);

  factory Uint200.fromHex(String hex) => Uint200(hexToInt(hex));
  factory Uint200.fromBytes(Bytes bytes) => Uint200(bytesToUnsignedInt(bytes));

  @override
  Uint200 _create(BigInt value) => Uint200(value);

  @override
  int get bitWidth => 200;
}

// ============================================================================
// Uint208 - 208-bit unsigned integer
// ============================================================================

class Uint208 extends _Uint {
  Uint208(super._value);

  static Uint208 get zero => Uint208(BigInt.zero);
  static Uint208 get max => Uint208((BigInt.one << 208) - BigInt.one);

  factory Uint208.fromHex(String hex) => Uint208(hexToInt(hex));
  factory Uint208.fromBytes(Bytes bytes) => Uint208(bytesToUnsignedInt(bytes));

  @override
  Uint208 _create(BigInt value) => Uint208(value);

  @override
  int get bitWidth => 208;
}

// ============================================================================
// Uint216 - 216-bit unsigned integer
// ============================================================================

class Uint216 extends _Uint {
  Uint216(super._value);

  static Uint216 get zero => Uint216(BigInt.zero);
  static Uint216 get max => Uint216((BigInt.one << 216) - BigInt.one);

  factory Uint216.fromHex(String hex) => Uint216(hexToInt(hex));
  factory Uint216.fromBytes(Bytes bytes) => Uint216(bytesToUnsignedInt(bytes));

  @override
  Uint216 _create(BigInt value) => Uint216(value);

  @override
  int get bitWidth => 216;
}

// ============================================================================
// Uint224 - 224-bit unsigned integer
// ============================================================================

class Uint224 extends _Uint {
  Uint224(super._value);

  static Uint224 get zero => Uint224(BigInt.zero);
  static Uint224 get max => Uint224((BigInt.one << 224) - BigInt.one);

  factory Uint224.fromHex(String hex) => Uint224(hexToInt(hex));
  factory Uint224.fromBytes(Bytes bytes) => Uint224(bytesToUnsignedInt(bytes));

  @override
  Uint224 _create(BigInt value) => Uint224(value);

  @override
  int get bitWidth => 224;
}

// ============================================================================
// Uint232 - 232-bit unsigned integer
// ============================================================================

class Uint232 extends _Uint {
  Uint232(super._value);

  static Uint232 get zero => Uint232(BigInt.zero);
  static Uint232 get max => Uint232((BigInt.one << 232) - BigInt.one);

  factory Uint232.fromHex(String hex) => Uint232(hexToInt(hex));
  factory Uint232.fromBytes(Bytes bytes) => Uint232(bytesToUnsignedInt(bytes));

  @override
  Uint232 _create(BigInt value) => Uint232(value);

  @override
  int get bitWidth => 232;
}

// ============================================================================
// Uint240 - 240-bit unsigned integer
// ============================================================================

class Uint240 extends _Uint {
  Uint240(super._value);

  static Uint240 get zero => Uint240(BigInt.zero);
  static Uint240 get max => Uint240((BigInt.one << 240) - BigInt.one);

  factory Uint240.fromHex(String hex) => Uint240(hexToInt(hex));
  factory Uint240.fromBytes(Bytes bytes) => Uint240(bytesToUnsignedInt(bytes));

  @override
  Uint240 _create(BigInt value) => Uint240(value);

  @override
  int get bitWidth => 240;
}

// ============================================================================
// Uint248 - 248-bit unsigned integer
// ============================================================================

class Uint248 extends _Uint {
  Uint248(super._value);

  static Uint248 get zero => Uint248(BigInt.zero);
  static Uint248 get max => Uint248((BigInt.one << 248) - BigInt.one);

  factory Uint248.fromHex(String hex) => Uint248(hexToInt(hex));
  factory Uint248.fromBytes(Bytes bytes) => Uint248(bytesToUnsignedInt(bytes));

  @override
  Uint248 _create(BigInt value) => Uint248(value);

  @override
  int get bitWidth => 248;
}

// ============================================================================
// Uint256 - 256-bit unsigned integer
// ============================================================================

class Uint256 extends _Uint {
  Uint256(super._value);

  static Uint256 get zero => Uint256(BigInt.zero);
  static Uint256 get max => Uint256((BigInt.one << 256) - BigInt.one);

  factory Uint256.fromHex(String hex) => Uint256(hexToInt(hex));
  factory Uint256.fromBytes(Bytes bytes) => Uint256(bytesToUnsignedInt(bytes));
  factory Uint256.fromString(String value) => Uint256(BigInt.parse(value));

  @override
  Uint256 _create(BigInt value) => Uint256(value);

  @override
  int get bitWidth => 256;
}

/// Validates that a value is within the bounds for a Uint type.
void _validateBounds(BigInt value, int bitWidth) {
  final maxValue = (BigInt.one << bitWidth) - BigInt.one;
  if (value < BigInt.zero || value > maxValue) {
    throw ArgumentError(
      'Value $value is out of bounds for Uint$bitWidth. '
      'Must be between 0 and $maxValue.',
    );
  }
}

// ============================================================================
// Base class - shared implementation for all Uint types
// ============================================================================

/// Base interface for unsigned integer types of various bit widths.
///
/// This interface defines common operations and conversions for unsigned integers
/// supporting all Solidity Uint types (uint8 to Uint256 in 8-bit increments).
/// Each concrete implementation enforces its own bit width constraints.
abstract interface class _Uint {
  /// The underlying BigInt value.
  final BigInt _value;

  /// The bit width of this unsigned integer type.
  int get bitWidth;

  _Uint(this._value) {
    _validateBounds(value, bitWidth);
  }

  /// Gets the underlying BigInt value.
  BigInt get value => _value;

  /// The maximum value this unsigned integer can hold.
  BigInt get _maxValue => (BigInt.one << bitWidth) - BigInt.one;

  /// The hexadecimal string length for this Uint type.
  int get _hexLength => (bitWidth / 4).ceil();

  // Arithmetic operators
  _Uint operator +(_Uint other) => _create((_value + other._value) & _maxValue);
  _Uint operator -(_Uint other) => _create((_value - other._value) & _maxValue);
  _Uint operator *(_Uint other) => _create((_value * other._value) & _maxValue);
  _Uint operator /(_Uint other) => _create(_value ~/ other._value);
  _Uint operator %(_Uint other) => _create(_value % other._value);

  // Bitwise operators
  _Uint operator &(_Uint other) => _create(_value & other._value);
  _Uint operator |(_Uint other) => _create(_value | other._value);
  _Uint operator ^(_Uint other) => _create(_value ^ other._value);
  _Uint operator ~() => _create((~_value) & _maxValue);
  _Uint operator <<(int shift) => _create((_value << shift) & _maxValue);
  _Uint operator >>(int shift) => _create(_value >> shift);

  // Comparison operators
  bool operator <(_Uint other) => _value < other._value;
  bool operator <=(_Uint other) => _value <= other._value;
  bool operator >(_Uint other) => _value > other._value;
  bool operator >=(_Uint other) => _value >= other._value;

  @override
  bool operator ==(Object other) =>
      other is _Uint && _value == other._value && bitWidth == other.bitWidth;

  @override
  int get hashCode => Object.hash(_value, bitWidth);

  /// Converts this Uint to a hexadecimal string with '0x' prefix.
  String toHex() => '0x${toString()}';

  /// Converts this Uint to an integer.
  int toInt() => _value.toInt();

  /// Converts this Uint to a byte list.
  Bytes toBytes() => unsignedIntToBytes(_value);

  /// Pads the hexadecimal representation with leading zeros.
  _Uint padLeft() => _create(hexToInt(toString().padLeft(_hexLength, '0')));

  /// Pads the hexadecimal representation with trailing zeros.
  _Uint padRight() => _create(hexToInt(toString().padRight(_hexLength, '0')));

  /// Applies a transformation function to this Uint's value.
  _Uint let(BigInt Function(BigInt) transform) => _create(transform(_value));

  @override
  String toString() => _value.toRadixString(16);

  /// Internal factory method to create instances of the correct subtype.
  ///
  /// This is the key to making the base class work polymorphically:
  /// - When you call `uint8(5) + Uint8(3)`, the `+` operator is defined in _Uint
  /// - The base class needs to return a Uint8, not a generic _Uint
  /// - So it calls `_create()`, which each subclass overrides to return its specific type
  /// - This way, Uint8 + Uint8 = Uint8, Uint256 + Uint256 = Uint256, etc.
  ///
  /// Without _create(), all operations would return base _Uint instances and lose type information.
  _Uint _create(BigInt value);
}

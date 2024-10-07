part of 'interfaces.dart';

class SignatureOptions {
  final List<int> _prefix;

  Uint8List get prefix => Uint8List.fromList(_prefix);

  const SignatureOptions({List<int> prefix = const []}) : _prefix = prefix;
}

class PassKeysOptions<T> extends SignatureOptions {
  final String namespace;
  final String name;
  final String origin;
  String? challenge;
  String? type;

  final EthereumAddress sharedWebauthnSigner;
  final String userVerification;
  final bool requireResidentKey;

  PassKeysOptions(
      {super.prefix,
      required this.namespace,
      required this.name,
      required this.origin,
      required this.sharedWebauthnSigner,
      this.userVerification = "required",
      this.requireResidentKey = true,
      this.challenge,
      this.type});
}

class FCLSignature {
  final String staticSignature;
  final String dynamicPartLength;
  final String data;
  const FCLSignature(this.staticSignature, this.dynamicPartLength, this.data);

  Uint8List toUint8List() {
    return hexToBytes(toString());
  }

  Map<String, String> toMap() {
    return {
      'staticSignature': "0x$staticSignature",
      'dynamicPartLength': "0x$dynamicPartLength",
      'data': "0x$data",
    };
  }

  String toJson() => json.encode(toMap());

  factory FCLSignature.fromMap(Map<String, String> map) {
    return FCLSignature(
        hexStripPrefix(map['staticSignature']!),
        hexStripPrefix(map['dynamicPartLength']!),
        hexStripPrefix(map['data']!));
  }

  factory FCLSignature.fromJson(String json) {
    return FCLSignature.fromMap(Map<String, String>.from(jsonDecode(json)));
  }

  @override
  String toString() {
    return "0x$staticSignature$dynamicPartLength$data";
  }
}

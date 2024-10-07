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
  final Uint8List staticSignature;
  final Uint8List dynamicPartLength;
  final Uint8List data;

  const FCLSignature(this.staticSignature, this.dynamicPartLength, this.data);

  Uint8List toUint8List() {
    return staticSignature.concat(dynamicPartLength).concat(data);
  }

  @override
  String toString() {
    return hexlify(toUint8List());
  }
}

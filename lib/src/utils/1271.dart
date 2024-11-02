part of 'utils.dart';

enum ERC1271IsValidSignatureResponse {
  sucess("0x1626ba7e"),
  failure("0xffffffff");

  final String value;

  const ERC1271IsValidSignatureResponse(this.value);

  factory ERC1271IsValidSignatureResponse.isValid(bool value) {
    return value ? sucess : failure;
  }

  factory ERC1271IsValidSignatureResponse.isValidResult(Uint256 result) {
    return result.value == BigInt.one ? sucess : failure;
  }
}

ERC1271IsValidSignatureResponse isValidPersonalSignature(
    Uint8List message, Uint8List signature, EthereumAddress address) {
  final prefix = '\u0019Ethereum Signed Message:\n${message.length}';
  final prefixBytes = ascii.encode(prefix);
  final payload = prefixBytes.concat(message);
  final signer = ecRecover(
      keccak256(payload),
      MsgSignature(bytesToInt(signature.sublist(0, 32)),
          bytesToInt(signature.sublist(32, 64)), signature[64]));
  return ERC1271IsValidSignatureResponse.isValid(
      EthereumAddress.fromPublicKey(signer).hex == address.hex);
}

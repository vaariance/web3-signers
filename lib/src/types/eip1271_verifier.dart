part of '../../web3_signers.dart';

/// Utility class for verifying signatures according to EIP-1271.
///
/// This class provides static methods to validate signatures for contracts
/// (using `isValidSignature`) and standard EOAs (using ECDSA recovery),
/// including support for Passkeys (WebAuthn).
final class Eip1271Verifier {
  const Eip1271Verifier._();

  /// Verifies a signature against a smart contract using EIP-1271.
  ///
  /// Calls the `isValidSignature(bytes32,bytes)` method on the [contractAddress].
  ///
  /// Parameters:
  /// - [hash]: The 32-byte hash of the data that was signed.
  /// - [signature]: The signature bytes to verify.
  /// - [contractAddress]: The address of the smart contract.
  /// - [rpcUrl]: The RPC URL to use for the `eth_call`.
  ///
  /// Returns a valid response if the contract returns the magic value `0x1626ba7e`.
  ///
  /// Example:
  /// ```dart
  /// final isValid = await Eip1271Verifier.isValidContractSignature(
  ///   keccak256(rawPayload),
  ///   signature,
  ///   contractAddress,
  ///   "https://mainnet.infura.io/v3/..."
  /// );
  /// ```
  static Future<ERC1271IsValidSignatureResponse> isValidContractSignature(
    Bytes hash,
    Bytes signature,
    HexString contractAddress,
    String rpcUrl,
  ) async {
    final selector = hexToBytes("1626ba7e");
    final encoded = Abi.encode(['bytes32', 'bytes'], [hash, signature]);
    final calldata = selector.concat(encoded);

    final result = await _rpcRequest(calldata, contractAddress, rpcUrl);

    return ERC1271IsValidSignatureResponse.isValidResult(result);
  }

  /// Verifies an ECDSA signature for a raw payload.
  ///
  /// Supports both standard ECDSA signatures and Passkey (WebAuthn) signatures
  /// by reconstructing the client data JSON if necessary.
  ///
  /// Parameters:
  /// - [preImage]: The original data that was signed (do not hash first).
  /// - [signature]: The signature object containing `r`, `s`, `v`, and optional WebAuthn data.
  /// - [signer]: The public key of the signer to verify against.
  ///
  /// Example:
  /// ```dart
  /// final isValid = Eip1271Verifier.isValidECSignature(
  ///   rawPayload,
  ///   signature,
  ///   signerPublicKey
  /// );
  /// ```
  static ERC1271IsValidSignatureResponse isValidECSignature(
    Bytes preImage,
    Signature signature,
    PublicKey signer,
  ) {
    final payload = _getPayload(preImage, signature);
    return _ecRecover(payload, signature, signer);
  }

  /// Verifies an Ethereum Signed Message (EIP-191).
  ///
  /// Wraps the message with the standard prefix "\x19Ethereum Signed Message:\n"
  /// before verification.
  ///
  /// Parameters:
  /// - [message]: The raw message bytes.
  /// - [signature]: The signature to verify.
  /// - [signer]: The public key of the expected signer.
  ///
  /// Example:
  /// ```dart
  /// final isValid = Eip1271Verifier.isValidSignedMessage(
  ///   utf8.encode("Hello World"),
  ///   signature,
  ///   signerPublicKey
  /// );
  /// ```
  static ERC1271IsValidSignatureResponse isValidSignedMessage(
    Bytes message,
    Signature signature,
    PublicKey signer,
  ) {
    final prefix = '\u0019Ethereum Signed Message:\n${message.length}';
    final prefixBytes = ascii.encode(prefix);
    final payload = _getPayload(prefixBytes.concat(message), signature);
    return _ecRecover(payload, signature, signer);
  }

  /// Verifies an EIP-712 Typed Data signature.
  ///
  /// Hashes the typed data according to the spec before verification.
  ///
  /// Parameters:
  /// - [typedData]: The EIP-712 typed message.
  /// - [version]: The EIP-712 version to use for hashing.
  /// - [signature]: The signature to verify.
  /// - [signer]: The public key of the expected signer.
  ///
  /// Example:
  /// ```dart
  /// final isValid = Eip1271Verifier.isValidSignedTypedData(
  ///   TypedMessage.fromJson({...}),
  ///   TypedDataVersion.V4,
  ///   signature,
  ///   signerPublicKey
  /// );
  /// ```
  static ERC1271IsValidSignatureResponse isValidSignedTypedData(
    TypedMessage typedData,
    TypedDataVersion version,
    Signature signature,
    PublicKey signer,
  ) {
    final message = hashTypedData(typedData: typedData, version: version);
    final payload = _getPayload(message, signature);
    return _ecRecover(payload, signature, signer);
  }

  static ERC1271IsValidSignatureResponse _ecRecover(
    Bytes payload,
    Signature signature,
    PublicKey signer,
  ) {
    final params = signature.curve!.curveParams;
    final Q = params.curve.createPoint(signer.x.value, signer.y.value);
    final ecPubKey = ECPublicKey(Q, params);
    final ecSigner = ECDSASigner(signature.curve!.digest);
    ecSigner.init(false, PublicKeyParameter(ecPubKey));

    final valid = ecSigner.verifySignature(payload, signature);
    return ERC1271IsValidSignatureResponse.isValid(valid);
  }

  static Bytes _getPayload(Bytes message, Signature signature) {
    if (signature.authData == null && signature.clientDataJson == null) {
      return message;
    }
    final hashBase64 = b64e(message);
    final match = cdjRgExp.firstMatch(signature.clientDataJson!)!;
    final clientDataJSON =
        '{"type":"webauthn.get","challenge":"$hashBase64",${match[1]}}';
    final clientHash = sha256Hash(utf8.encode(clientDataJSON));
    return signature.authData!.concat(Uint8List.fromList(clientHash));
  }

  static Future<Uint32> _rpcRequest(
    Uint8List calldata,
    String contractAddress,
    String rpcUrl,
  ) async {
    final client = HttpClient();
    final String requestBody = json.encode({
      'jsonrpc': '2.0',
      'method': 'eth_call',
      'params': [
        {'to': contractAddress, 'data': hexlify(calldata)},
        'latest',
      ],
      'id': 1,
    });
    try {
      final Uri uri = Uri.parse(rpcUrl);
      final HttpClientRequest request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(requestBody));

      final HttpClientResponse response = await request.close();
      final String responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (jsonResponse.containsKey('error')) {
        return Uint32.zero;
      } else if (jsonResponse.containsKey('result')) {
        return Uint32.fromHex(jsonResponse['result']);
      } else {
        return Uint32.zero;
      }
    } catch (e) {
      return Uint32.zero;
    } finally {
      client.close();
    }
  }
}

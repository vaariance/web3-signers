import 'package:web3_signers/web3_signers.dart';

// P256 Public Key (X and Y coordinates) from valid test data
const p256PublicKeyX =
    "0xedf717baff9a87fd4b031a2a066580a9a29bdba97e2fd55820f7cd5c963f09ae";
const p256PublicKeyY =
    "0x276c0acd7ed3c8ad8db88f0c15f5d19b12aaa2af3f26c9003e07afd95b980fe5";

// Credential ID (Base64 URL Safe)
const credentialId = "xLY8if5aHhPNSToeYXXOpA";

// Associated PassKeyPublicKey
PassKeyPublicKey get testP256PublicKey {
  return PassKeyPublicKey(
    x: Uint256.fromHex(p256PublicKeyX),
    y: Uint256.fromHex(p256PublicKeyY),
    // credentialId is stored as Bytes in PassKeyPublicKey
    credentialId: b64d(credentialId),
    userName: "Test User",
    aaGuid: "00000000-0000-0000-0000-000000000000",
  );
}

// Valid response data for the above key and a challenge of 32 zero bytes
const validAuthenticatorData =
    "TjGXzAiZUHkjJiaVfkQODGrY7iI99BhKRPZA4cYXaW0dAAAAAA";
const validSignature =
    "MEQCIB0xbkk_A9dhf63DMqVIkYevEVYi0-HmSMGrcmkvahCrAiBnC0WhB1Hm0Wulzwudf1w8KpAXbtOjz8Qbl9vO3xYZHw";
const validClientDataJSON =
    "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQSIsIm9yaWdpbiI6ImFuZHJvaWQ6YXBrLWtleS1oYXNoOjUtLVhoaHJwTmVIX0syYVlweFl4T3VwelJaWmtCejFkR1VUdXdEVWFETkkiLCJhbmRyb2lkUGFja2FnZU5hbWUiOiJjb20uZXhhbXBsZS53ZWIzX3NpZ25lcnMifQ";
const validUserHandle = "2on6z7AARXOKnB8-U-Mtyw";

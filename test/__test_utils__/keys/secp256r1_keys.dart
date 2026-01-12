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

const testRegisterResponse = {
  "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiYnVITHpGLTk0XzBCZENMcklpOThMNDBLUlNfNl9HSlhMM0tsTC04M3hkayIsIm9yaWdpbiI6ImFuZHJvaWQ6YXBrLWtleS1oYXNoOjUtLVhoaHJwTmVIX0syYVlweFl4T3VwelJaWmtCejFkR1VUdXdEVWFETkkiLCJhbmRyb2lkUGFja2FnZU5hbWUiOiJjb20uZXhhbXBsZS53ZWIzX3NpZ25lcnMifQ", // clientdatajson
  "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YViUTjGXzAiZUHkjJiaVfkQODGrY7iI99BhKRPZA4cYXaW1dAAAAAOqbjWZNAR0hPOS2tIy1ddQAEMS2PIn-Wh4TzUk6HmF1zqSlAQIDJiABIVgg7fcXuv-ah_1LAxoqBmWAqaKb26l-L9VYIPfNXJY_Ca4iWCAnbArNftPIrY24jwwV9dGbEqqirz8myQA-B6_ZW5gP5Q", // attestationobject
};

const sePubKeyx =
    "0x09e53498f71de00890178392be5dca2d44f957de0b62a900e65cd5d8d62d916e";
const sePubKeyy =
    "0xbadd9eabf4f62c6de39016715614bd30f1e76efa681f1f58c4028655d9f6e45b";
const seCreateRes =
    "0409e53498f71de00890178392be5dca2d44f957de0b62a900e65cd5d8d62d916ebadd9eabf4f62c6de39016715614bd30f1e76efa681f1f58c4028655d9f6e45b";
const seMessage = "hello, world!";
const seSignResponse =
    "0x30450220309e4e8a33c3d6c9caa09c795528570402c586bd3dd18ae054456aae99513953022100ce6d2a9bd93b9dd9db194a35456d1a2633d5da644d6dbcf402059749a4b02f65";
const seSigR =
    "0x309e4e8a33c3d6c9caa09c795528570402c586bd3dd18ae054456aae99513953";
const seSigS =
    "0x3192d56326c4622724e6b5caba92e5d98911204959a9e190f1b4337957b2f5ec";
const seYparity = 1;

// 'authData' in CBOR is a text string (Major Type 3).
// The header byte for a 8-byte string "authData" is 0x60 | 8 = 0x68.
// The UTF-8 bytes for "authData" are [0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61].
const authDataPattern = [0x68, 0x61, 0x75, 0x74, 0x68, 0x44, 0x61, 0x74, 0x61];

const dummyCdField =
    '{"type":"webauthn.get","challenge":"p5aV2uHXr0AOqUk7HQitvi-Ny1p5aV2uHXr0AOqUk7H","origin":"android:apk-key-hash:5--XhhrpNeH_K2aYpxYxOupzRZZkBz1dGUTuwDUaDNI","androidPackageName":"com.example.web3_signers"}';

const eip191MessagePrefix = '\u0019Ethereum Signed Message:\n';

const derivationPath = "m/44'/60'/0'/0/0";

final defaultP256Verifier = "0x${'0' * 37}100";

RegExp cdjRgExp = RegExp(
  r'^\{"type":"webauthn.get","challenge":"[A-Za-z0-9\-_]{43}",(.*)\}$',
);

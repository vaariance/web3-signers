# Test Suite Refactoring Plan

## Directory Structure

The `test` directory will be reorganized as follows:

```
test/
├── _old/                     # Archived existing tests
├── __test_utils__/           # Shared test utilities
│   ├── fixtures/             # Test constants and static data
│   │   └── constants.dart    # General constants
│   ├── keys/                 # Private keys, public keys, and key generation helpers
|   |   ├── p256_keys.dart
|   |   └── secp256k1_keys.dart
│   └── mocks/                # Mock classes (e.g., using Mockito)
│       └── mock_server.dart
├── core/                     # Tests for src/core
│   ├── bip32_test.dart
│   ├── bip39_test.dart
│   └── ec_api_test.dart
├── signing/                  # Tests for src/signing
│   ├── localkey_signer_test.dart
│   ├── passkey_signer_test.dart
│   └── platformkey_signer_test.dart
├── types/                    # Tests for src/types
│   ├── bytes_test.dart
│   ├── eip1271_verifier_test.dart
│   └── abi_coder_test.dart
└── utils/                    # Tests for src/utils (if needed)
```

## Test Specifications

### 1. `__test_utils__`
- **Fixtures**: Move all hardcoded strings (contract addresses, long data strings, expected outputs) here.
- **Keys**: unique valid and invalid keys for testing.
- **Mocks**: Mocks for `RPC`, `HttpClient`, or external dependencies.

### 2. Signer Tests
- **LocalKeySigner**:
  - Test `personalSign` (EIP-191).
  - Test `signTypedData` (EIP-712).
  - Test usage with both `String` (hex) and `Bytes` inputs if applicable.
  - Verify address derivation.
  
- **PassKeySigner**:
  - Test `personalSign`.
  - Test `signTypedData`.
  - Mock the authenticator responses.
  
- **PlatformKeySigner**:
  - Test `personalSign`.
  - Mock the platform interactions.

### 3. Verifier Tests (`Eip1271Verifier`)
- **isValidContractSignature**:
  - Mock RPC response for `eth_call`.
  - Test valid magic value response.
  - Test invalid response.
- **isValidECSignature**:
  - Test valid recoverable signature.
  - Test invalid signature.
- **isValidSignedMessage**:
  - Test with `LocalKeySigner` output.
- **isValidSignedTypedData**:
  - Test with `EIP-712` data.

### 4. Core Tests
- Verify BIP39 mnemonic generation.
- Verify BIP32 derivation paths.

## Migration Steps
1. Create `test/_old` and move existing files related to `eoa_wallet`, `passkey_signer`, etc.
2. Create the `__test_utils__` directory structure.
3. Migrate useful constants and keys from `_old/constant.dart` to `__test_utils__/fixtures` and `__test_utils__/keys`.
4. Implement new test files one by one, starting with `localkey_signer_test.dart` and `eip1271_verifier_test.dart`.

# web3_signers

![Pub Version](https://img.shields.io/pub/v/web3_signers)
![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)
[![Coverage Status](https://coveralls.io/repos/github/vaariance/web3-signers/badge.svg?branch=main)](https://coveralls.io/github/vaariance/web3-signers?branch=main)

**A generic signing interface for Smart Accounts (ERC-4337, EIP-7702), ERC-1271, and ERC-7739 validation.**

This package provides a unified `Signer` interface to interact with various authentication credentials - Passkeys (WebAuthn), Platform Keys (Secure Enclave/TPM), and Local Private Keys. It allows developers to build Smart Account signers that are decoupled from specific wallet implementations, making it a foundational building block for any AA SDK or dApp.

> [!WARNING]
> **Migrating from v0.x?**
>
> Significant breaking changes were introduced in v1.0.0. Please refer to the [Migration Guide](MIGRATION.md).

## Features

- 🔐 **Passkeys (WebAuthn)**: Biometric and FIDO2 signing with configurable attestation and transports.
- 🛡️ **Platform Keys**: Hardware-backed keys using Secure Enclave (iOS/macOS), Keystore (Android), and Windows Hello.
- 🔑 **Local Keys**: Memory-based private key signing for ephemeral sessions or recovery.
- ⚡ **Standard Compliant**: Native support for EIP-1271 and ERC-7739 protections.
- 📱 **Cross-Platform**: Unified API for Android, iOS, macOS, Windows, and Web (partial).

## Platform Requirements

| Platform | Minimum Version | Notes |
|----------|-----------------|-------|
| **Android** | Android 11 (API 30)+ | Required for modern biometric/keystore features. |
| **iOS** | iOS 13.0+ | Supports Secure Enclave and Authentication Services. |
| **macOS** | macOS 10.15+ (Catalina) | Supports Touch ID and platform authenticators. |
| **Windows** | Windows 10/11 | Requires CMake 3.14+ for build. |

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  web3_signers: ^1.0.0
```

## Usage

### 1. Local Private Keys

*Best for: Development, testing, ephemeral session keys, or where users handle their own seed phrases.*

```dart
import 'package:web3_signers/web3_signers.dart';

// Option A: Generate a random private key (for new wallets)
final privateKey = generatePrivateKey(); 

// Option B: Derive from a mnemonic
// 1. Generate a new mnemonic or use an existing one
 final mnemonic = generateMnemonic(WordLength.word_12);
// 2. Derive the private key (supports optional custom path)
 final privateKey = mnemonicToPrivateKey("your twelve word mnemonic ...", "m/44'/60'/0'/0/0");

// 3. Create the signer
// Direct from private key bytes:
final signer = LocalKeySigner.fromRawPrivateKey(privateKey);

// OR directly from a mnemonic string:
final signerFromMnemonic = LocalKeySigner.fromMnemonic("your twelve word mnemonic ...");
```

### 2. Passkeys (WebAuthn)

*Best for: Main account keys, biometric security, convenient cross-device access.*

**Step 1: Configuration**:
Define your Relying Party (RP) settings. This MUST match your domain.

```dart
final pkConfig = PassKeyConfig(
  rpId: "app.example.com", 
  rpName: "Example App",
  timeout: 60000, 
  userVerification: "required",
);
```

**Step 2: Credential Creation (Registration)**:
Prompt the user to create a new passkey.

```dart
// Returns the public key and credential metadata
final pkPublicKey = await generatePassKey(
  config: pkConfig,
  username: "user@example.com",
  displayname: "User Name",
  attestationLevel: PasskeyAttestationLevel.none, 
  // challenge is optional; a random one is generated if omitted
  // auth is optional; a default is used if omitted
);
```

**Step 3: Signer Instantiation**

```dart
// Standard instantiation
final signer = PassKeySigner.withConfig(pkConfig, pkPublicKey);

// Advanced: Inject a custom authenticator instance (useful for dependency injection or reuse in key generation)
final auth = PasskeyAuthenticator();
final signer = PassKeySigner.withAuthenticator(auth, pkConfig, pkPublicKey);
```

### 3. Platform Keys (Secure Enclave / Keystore)

*Best for: Device-specific keys, high-security hardware backing without WebAuthn prompts.*

**Step 1: Configuration**:
Platform keys offer granular control over security and UI via `AndroidPlatformOptions`, `DarwinPlatformOptions`, and `WindowsPlatformOptions`.

```dart
final platformConfig = PlatformConfig(
  keyTag: "com.example.app.signing_key", 
  
  // Android: Prefer StrongBox, require authentication
  androidOptions: AndroidPlatformOptions(
    useStrongBoxKeyMint: true,
    requireUserAuthentication: true,
    authTimeoutSeconds: 0, // 0 means authenticate every time
    // ... optional parameters 
  ),
  
  // iOS/macOS: Use Secure Enclave, strict access control
  darwinOptions: DarwinPlatformOptions(
    useSecureEnclave: true, // false uses keychain sharing (ensure entitlements are set)
    accessible: DarwinAccessible.whenUnlockedThisDeviceOnly,
    // ... other optional parameters 
  ),

  // Windows: Use TPM, custom prompt text
  windowsOptions: WindowsPlatformOptions(
    useTpm: true,
    // ui policy is enforced by the presense of a `requireUserAuthentication` flag
    requireUserAuthentication: true,
    uiPolicyFriendlyName: "My App Wallet",
    uiPolicyDescription: "Sign transactions for My App Wallet",
    // ... other optional parameters 
  ),
);
```

**Step 2: Key Generation**

```dart
final platformPublicKey = await generatePlatformKey(
  config: platformConfig,
  checkExisting: true, // Reuse existing key if present
  // auth is optional; a default is used if omitted
);
```

**Step 3: Signer Instantiation**

```dart
// Standard instantiation
final signer = PlatformKeySigner.withConfig(platformConfig, platformPublicKey);

// To delete the key later (irreversible):
await signer.deleteSigningKey();

// Advanced: Inject a custom authenticator instance (useful for dependency injection or reuse in key generation)final auth = PlatformAuthenticator();
final signer = PlatformKeySigner.withAuthenticator(
  auth, 
  platformConfig, 
  platformPublicKey
);
```

## Signer Interface

All signers implement the `Signer` interface, providing a consistent way to interact with keys.

### Properties

```dart
// The signer's public key (PlatformPublicKey, PassKeyPublicKey, or LocalPublicKey)
final publicKey = signer.publicKey;

// The Ethereum address derived from the public key
final address = signer.getAddress();

// The type of signer (localKey, platformKey, passKey)
final type = signer.kind;

// Capabilities
final canSyncSign = signer.supportsSyncSigning; // True for LocalKeySigner
final supportsUserPresence = signer.supportsUserPresence; // True for Passkey/Platform
```

### Signing Methods

**1. Async Signing (Preferred)**
Most compatible method, handles UI prompts for Passkeys/Platform keys.

```dart
final signature = await signer.signAsync(messageBytes);
```

**2. Synchronous Signing**
Only available if `supportsSyncSigning` is true (e.g., `LocalKeySigner`).

```dart
if (signer.supportsSyncSigning) {
    try {
        final signature = signer.sign(messageBytes);
    } catch (e) {
        // Handle error: Signer does not support sync signing
    }
}
```

**3. Personal Sign (EIP-191)**
Prefixes the message with `\x19Ethereum Signed Message:\n...` before signing.

```dart
final signature = await signer.personalSign(ascii.encode("Hello Ethereum"));
```

**4. Typed Data (EIP-712)**
Signs structured data.

```dart
final signature = await signer.signTypedData(
    typedParams, 
    TypedDataVersion.V4
);
```

## Signature Verification

Use the `Verifier` class to validate signatures, including Smart Account (EIP-1271) signatures.

```dart
import 'package:web3_signers/web3_signers.dart';

// 1. Verify a Contract Signature (EIP-1271/7739)
final isValid = await Verifier.isValidContractSignature(
  hash,
  signatureBytes, // typed data bytes if using 7739 
  contractAddress,
  "https://rpc.example.com",
);

if (isValid == IsValidSignatureResponse.success) {
    print("Contract signature is valid!");
}

// 2. Verify an EOA/EC Signature
final isValidEC = Verifier.isValidECSignature(
    originalPayload, 
    signature, 
    signerPublicKey
);
```

## License

This project is licensed under the [BSD 3-Clause License](LICENSE).
